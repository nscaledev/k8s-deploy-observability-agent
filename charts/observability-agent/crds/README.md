# Vendored CRDs

This directory contains OpenTelemetry custom resource definitions that must exist before the chart creates resources depending on them. Vendoring the CRDs here ensures Helm installs them first and avoids "no matches for kind" validation errors when using the OpenTelemetry Operator subchart.

## Included CRDs

### OpenTelemetry Operator (0.92.5)
- `opentelemetrycollector.yaml` – Defines the `OpenTelemetryCollector` resource
- `targetallocators.yaml` – Defines the `TargetAllocator` resource
- `instrumentations.yaml` – Defines the `Instrumentation` resource

## Updating CRDs

Run the helper script from the repository root to refresh the vendored OpenTelemetry CRDs:

```bash
./scripts/update-crds.sh
```

You can override the version or configuration when needed:

```bash
./scripts/update-crds.sh --otel-version 0.92.5
./scripts/update-crds.sh --otel-namespace telemetry-system --otel-name opentelemetry-operator
```

The OpenTelemetry CRDs are rendered with a fixed namespace and name override. Keep the script arguments in sync with `values.yaml` (`opentelemetry-operator.fullnameOverride`) if you change them.

**Note**: Monitoring CRDs (ServiceMonitors, PodMonitors, etc.) are now managed by the kube-prometheus-stack subchart and no longer need to be vendored.

After updating:
1. Verify the chart installs successfully (`helm lint charts/observability-agent` and a test install).
2. Update documentation if version numbers changed.
3. Commit the refreshed CRDs.
