#!/bin/bash
set -euo pipefail

# Script to update vendored OpenTelemetry Operator CRDs
# Usage examples:
#   ./scripts/update-crds.sh
#   ./scripts/update-crds.sh --otel-version 0.92.5

OTEL_DEFAULT_VERSION="0.92.5"
OTEL_DEFAULT_NAMESPACE="telemetry-system"
OTEL_DEFAULT_NAME="observability-agent-opentelemetry-operator"
OTEL_VERSION="$OTEL_DEFAULT_VERSION"
OTEL_NAMESPACE="$OTEL_DEFAULT_NAMESPACE"
OTEL_NAME="$OTEL_DEFAULT_NAME"

CRD_DIR="charts/observability-agent/crds"
OTEL_CRD_NAMES=(
  "opentelemetrycollectors.opentelemetry.io"
  "targetallocators.opentelemetry.io"
  "instrumentations.opentelemetry.io"
)
OTEL_CRD_FILES=(
  "opentelemetrycollector.yaml"
  "targetallocators.yaml"
  "instrumentations.yaml"
)
OTEL_CHART_REPO="https://open-telemetry.github.io/opentelemetry-helm-charts"
OTEL_LOCAL_ARCHIVE="charts/observability-agent/charts/opentelemetry-operator-${OTEL_VERSION}.tgz"

usage() {
  cat <<USAGE
Usage: $0 [flags]

Flags:
  --otel-version <version>   OpenTelemetry Operator chart version to vendor (default: $OTEL_DEFAULT_VERSION)
  --otel-namespace <ns>      Namespace used for rendering CRDs (default: $OTEL_DEFAULT_NAMESPACE)
  --otel-name <name>         Full name override used by the operator (default: $OTEL_DEFAULT_NAME)
  -h, --help                 Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --otel-version)
      [[ $# -ge 2 ]] || { echo "Error: --otel-version requires a value" >&2; exit 1; }
      OTEL_VERSION="$2"
      OTEL_LOCAL_ARCHIVE="charts/observability-agent/charts/opentelemetry-operator-${OTEL_VERSION}.tgz"
      shift 2
      ;;
    --otel-namespace)
      [[ $# -ge 2 ]] || { echo "Error: --otel-namespace requires a value" >&2; exit 1; }
      OTEL_NAMESPACE="$2"
      shift 2
      ;;
    --otel-name)
      [[ $# -ge 2 ]] || { echo "Error: --otel-name requires a value" >&2; exit 1; }
      OTEL_NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument '$1'" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mkdir -p "$CRD_DIR"

tmp_dir=""
cleanup() {
  if [[ -n "$tmp_dir" && -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

echo "Updating OpenTelemetry Operator CRDs to chart version: $OTEL_VERSION"
  command -v helm >/dev/null 2>&1 || {
    echo "Error: helm is required to update OpenTelemetry Operator CRDs" >&2
    exit 1
  }

  tmp_dir="$(mktemp -d)"
  chart_archive="$tmp_dir/opentelemetry-operator-$OTEL_VERSION.tgz"

  if [[ -f "$OTEL_LOCAL_ARCHIVE" ]]; then
    echo "  - Using local chart archive $OTEL_LOCAL_ARCHIVE"
    cp "$OTEL_LOCAL_ARCHIVE" "$chart_archive"
  else
    echo "  - Fetching opentelemetry-operator chart"
    helm pull opentelemetry-operator \
      --repo "$OTEL_CHART_REPO" \
      --version "$OTEL_VERSION" \
      --destination "$tmp_dir" >/dev/null
  fi

  echo "  - Rendering CRDs"
  tar -xzf "$chart_archive" -C "$tmp_dir" opentelemetry-operator >/dev/null 2>&1
  chart_dir="$tmp_dir/opentelemetry-operator"
  rendered_file="$tmp_dir/opentelemetry-operator-rendered.yaml"

  helm template otel-crds "$chart_dir" \
    --include-crds \
    --skip-tests \
    --namespace "$OTEL_NAMESPACE" \
    --set crds.create=true \
    --set fullnameOverride="$OTEL_NAME" \
    --set namespaceOverride="$OTEL_NAMESPACE" \
    --set admissionWebhooks.certManager.enabled=true > "$rendered_file"

  found_targets=()
  process_doc() {
    local doc_content="$1"
    [[ -n "$doc_content" ]] || return 0
    [[ "$doc_content" == *"kind: CustomResourceDefinition"* ]] || return 0

    local idx
    for idx in "${!OTEL_CRD_NAMES[@]}"; do
      local crd_name="${OTEL_CRD_NAMES[$idx]}"
      if [[ "$doc_content" == *"name: $crd_name"* ]]; then
        local target_file="$CRD_DIR/${OTEL_CRD_FILES[$idx]}"
        printf '%s\n' "$doc_content" > "$target_file"
        echo "    ✓ ${OTEL_CRD_FILES[$idx]} updated"
        found_targets+=("$crd_name")
        break
      fi
    done
  }

  current_doc=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == '---' ]]; then
      process_doc "$current_doc"
      current_doc=""
    else
      current_doc+="$line"$'\n'
    fi
  done < "$rendered_file"
  process_doc "$current_doc"

  for crd_name in "${OTEL_CRD_NAMES[@]}"; do
    found=false
    for seen in "${found_targets[@]}"; do
      if [[ "$seen" == "$crd_name" ]]; then
        found=true
        break
      fi
    done
    if [[ "$found" == false ]]; then
      echo "    ✗ Failed to locate rendered CRD for $crd_name" >&2
      exit 1
    fi
  done
  echo ""

echo "CRD update complete. Current files:"
ls -1 "$CRD_DIR"

echo ""
echo "Next steps:"
echo "  1. Update documentation if versions changed"
echo "  2. Test the chart installation"
echo "  3. Commit the changes"
