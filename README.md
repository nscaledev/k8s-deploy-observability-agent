# K8S Deployment - Observability Agent

The Observability Agent components deployed on Nscale Kubernetes Service clusters.

| App                      | Description                                           | Version |
| ------------------------ | ----------------------------------------------------- | ------- |
| OpenTelemetry Operator   | Manages OpenTelemetry CRDs                            | 0.92.5  |
| OpenTelemetry CRDs       | Vendored CRDs for collector/allocator/instrumentation | 0.92.5  |
| OpenTelemetry Collector  | OTEL logs, metrics, traces collector                  | 0.131.1 |
| Prometheus Operator CRDs | Vendored CRDs for monitor config                      | 0.85.0  |

## Updating vendored CRDs

Edit target versions and run the script from the repository root to refresh both Prometheus and OpenTelemetry CRDs.
Vendored CRD versions should always match the operator version they are vendored from.

```bash
./scripts/update-crds.sh
```

