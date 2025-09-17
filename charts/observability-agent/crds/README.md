# Vendored CRDs

This directory contains custom resource definitions that must exist before the chart creates resources depending on them. Vendoring the CRDs here ensures Helm installs them first and avoids "no matches for kind" validation errors when using the OpenTelemetry Operator subchart.

## Included CRDs

### Prometheus Operator (v0.85.0)
- `servicemonitors.yaml` – Service-based metric scraping
- `podmonitors.yaml` – Pod-based metric scraping
- `scrapeconfigs.yaml` – Custom scrape configurations used by engineering
- `probes.yaml` – Prometheus blackbox probe configuration support

### OpenTelemetry Operator (0.92.5)
- `opentelemetrycollector.yaml` – Defines the `OpenTelemetryCollector` resource
- `targetallocators.yaml` – Defines the `TargetAllocator` resource
- `instrumentations.yaml` – Defines the `Instrumentation` resource

## Updating CRDs

Run the helper script from the repository root to refresh the vendored CRDs. By default it uses the versions recorded above and updates both Prometheus and OpenTelemetry CRDs.

```bash
./scripts/update-crds.sh
```

You can override versions or skip one of the providers when needed:

```bash
./scripts/update-crds.sh --prom-version v0.85.0 --otel-version 0.92.5
./scripts/update-crds.sh --skip-prom
./scripts/update-crds.sh --otel-namespace telemetry-system --otel-name opentelemetry-operator
```

The OpenTelemetry CRDs are rendered with a fixed namespace and name override. Keep the script arguments in sync with `values.yaml` (`opentelemetry-operator.namespaceOverride` and `fullnameOverride`) if you change them.

After updating:
1. Verify the chart installs successfully (`helm lint charts/observability-agent` and a test install).
2. Update documentation if version numbers changed.
3. Commit the refreshed CRDs.
