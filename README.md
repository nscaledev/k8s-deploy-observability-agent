# K8S Deployment - Template

A template which can be used to define a new deployment repo which will be applied to a cluster managed by Nscale.

This is just an example, and all values in the chart are not required, they are there as recommendations and can be
adjusted based on the requirements of the repo itself.

## Getting Started

### 1. Prepare the chart

First the `charts/example` needs updating to reflect the repo name. For example, a `k8s-deploy-gpu` would have
`charts/gpu`. Whilst this isn't required for automation or anything else, it's just nice practice to ensure we can
reference things correctly if/when required via automation.

Next, a new directory needs creating to store the chart's template files under `charts/example/template`. This is
where the manifests you require to be deployed will be stored.

Finally, the `charts/example/Chart.yaml` needs to be updated so that the `name`, `description`, `appVersion` and
`version` are all valid. Whilst we don't store charts in a legacy or OCI repo right now, the end goal will be to do so,
and as such it's good to get into good habits right away.

Once you've configured your chart, make sure you have adjusted the `charts/example/ci/test-example.yaml` to fit your
needs. You'll also need to update line 16 of `.github/kubeconform.sh` to match your file names. It presumes
`test-<something>.yaml`.

### 3. Update Repository Configuration

Make these additional changes to properly set up your new cluster repository:

1. Update CODEOWNERS:

   Edit `.github/CODEOWNERS` to specify the correct individuals or teams responsible for this code. Codeowners should be
   considered well. It should be the people who know the repo inside out and can decide a go/no-go on PRs.

### 4. Replace This README:

Replace this README.md with content specific to your deployment repo. It should contain a list of apps, a description
of what it's for and their versions. See the table below for an example.

| App                 | Description                | Version |
|---------------------|----------------------------|---------|
| ArgoCD              | GitOps tool                | 7.8.23  |
| Cert Manager        | Certificate management     | 1.17.0  |
| External Secrets    | External secret management | 0.14.1  |
| Grafana             | Metrics and logs dashboard | 8.9.0   |
| Loki                | Logs database              | 6.25.1  |
| Promtail            | Logs collection            | 6.16.6  |
| Prometheus          | Metrics collection         | 69.2.0  |
| Snapshot Controller | Snapshot management        | v1.1.0  |
| Teleport            | SSH access                 | 15.4.9  |
| Velero              | Backup and restore         | 8.3.0   |
