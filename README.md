# Plural Infrastructure Bootstrap Repository

This repository contains core infrastructure code and configurations to bootstrap a Plural management cluster and establish a GitOps environment using Plural. It includes Terraform modules, Kubernetes manifests, Helm charts, and other resources for managing clusters, global services, and common add-ons. It is designed to be cloned into your infrastructure repo and managed by your DevOps team.

We adhere to standard Terraform practices for Kubernetes across major cloud providers while provisioning essential add-ons such as load balancer controllers and autoscalers.

> [!TIP]
> If you want a guided walkthrough of how to use your new repo and get started with a Plural-based GitOps workflow, our [how-to guide](https://docs.plural.sh/how-to) is an amazing place to start!


## Repository Structure and Key Components

### Key Components and Resources

- VPC Network resources to establish cloud networking
- Kubernetes Control Plane and minimal worker nodes
- Postgres database for hosting your Plural Console instance

These defaults can be customized to suit your needs. Refer to the module documentation for configuring private clusters, modifying CIDR ranges, or enabling VPC peering.


## Folder Structure Overview

The repository contains the following main folders and their responsibilities:

```
helm-values/ # git-crypted helm values to be used to bootstrap your setup.  Avoid editing unless necessary
- ${app}.yaml # value overrides
- ${app}-defaults.yaml # default values we generate on install

helm/ # helm values files that are meant to be user-editable, used for setup of many common components
- *.yaml{.liquid} # `.liquid` extension signifies the helm values file can be templated

bootstrap/ # setup for apps within your cluster fleet, this is the root service-of-services that bootstraps everything recursively

resources/ # additional third party setup manifests for common k8s add-on concerns like observability and policy enforcement.  Can be useful learning resources, but no default setup uses thse

terraform/
  - mgmt # module for setting up your management cluster
  - core-infra # Sets up base networking and dns.  Can also be used for similar cross-cutting infra concerns
  - modules
  - - clusters
  - - - {cloud} # we've crafted some reusable modules for setting up clusters on most major clouds, feel free to use these in stacks or wherever
  - ${app}/ - submodule for individual app's terraform
```

- **terraform/**: Contains Terraform modules and stacks for provisioning clusters, core infrastructure, and cloud-specific resources.
- **setup/**: Resources and configurations for setting up clusters, global services, RBAC, notifications, PR automations, and more.
- **services/**: Pre-configured Kubernetes manifests and Helm charts for common services and add-ons like issuers and logstash.
- **helm/**: Helm values and chart templates used across the platform.
- **network/**: Manifests related to networking components such as load balancers and ingress controllers.
- **o11y/**: Observability-related manifests including metrics and logging.
- **existing/**: Sample existing setups and terraform code for various cloud providers.
- **test/**: Terraform and test resources for different cloud providers.



You're free to extend this as you'd like, although if you use the plural marketplace that structure will be expected.  You can also deploy services w/ manifests in other repos, this is meant to serve as a base to define the core infrastructure and get you started in a sane way.

## Working with the Plural Catalog and PR Automation

Many common Kubernetes infrastructure management operations are streamlined through the Plural service catalog, synced via `bootstrap/catalogs.yaml`. For example, to set up a new Kubernetes fleet, follow these steps:

1. Navigate to `{your-console-url}/self-service/catalogs` and select the `infra` catalog.
2. Choose the `cluster-fleet-creator` PR automation and complete the required fields.
3. Create the PR with an appropriate branch name. Once merged, it will provision dev and production clusters using the core-infra stack by default.

Other useful self-service setups in the catalog include:

- Data Infrastructure: Deploys Dagster, Airbyte, and MLflow
- Security Tooling: Installs Trivy Operator, OPA Gatekeeper
- DevOps Tools: Includes Elasticsearch log aggregation, Victoriametrics-based scalable Prometheus, Grafana, among others

## Adding Workload Clusters to Your Fleet

You can add workload clusters using various methods. Baseline Terraform modules are available in the `terraform/modules/clusters` directory. These modules can be deployed using stacks as documented [here](https://docs.plural.sh/stacks/overview).

We provide PR automation available at the `/pr/automations` endpoint in your Plural console to facilitate cluster provisioning. This automation will generate a PR containing the following resources:

- `InfrastructureStack`: Creates the underlying physical cluster
- `Cluster`: References the created cluster via a CRD, enabling other CRDs like `ServiceDeployment` to target it

For clusters created with your own automation, you can add them manually using the `plural` CLI:

```sh
plural cd clusters bootstrap --name {name}
```

Alternatively, you can reference clusters using the Terraform provider (e.g., see `terraform/modules/clusters/aws/plural.tf`).

To integrate clusters in GitOps resources, create a `Cluster` CRD similar to:

```yaml
apiVersion: deployments.plural.sh/v1alpha1
kind: Cluster
metadata:
  name: <name>
spec:
  handle: <name> # reference cluster handle
  tags:
    some: tag # optional tags
  metadata:
    arbitrary:
      yaml: metadata # arbitrary metadata for service templating (see https://docs.plural.sh/deployments/templating)
```

## Installing Low-level Kubernetes Operators

Plural offers tools to simplify fleet-wide deployment of Kubernetes operators. For operators such as cert-manager or Istio, use the `GlobalService` custom resource. More details are available in the [GlobalService documentation](https://docs.plural.sh/deployments/operator/global-service).

Example `GlobalService` definition for deploying ExternalDNS:

```yaml
apiVersion: deployments.plural.sh/v1alpha1
kind: GlobalService
metadata:
  name: externaldns
spec:
  tags:
    tier: dev # only target clusters with tier => dev tag pairs
  template:
    namespace: externaldns
    repositoryRef:
      kind: GitRepository
      name: infra
      namespace: infra
    git:
      ref: main
      folder: helm-values # or wherever else you want to store the helm values
    helm:
      version: 6.31.4
      chart: externaldns
      valuesFiles:
        - externaldns.yaml.liquid # use a liquid extension to enable templating in this file
      repository:
        namespace: infra
        name: externaldns
```

Refer to the `bootstrap/o11y` and `bootstrap/network` folders for working examples of global service installations for common Kubernetes runtime concerns. To undo the default setup, remove these resources and push the changes.