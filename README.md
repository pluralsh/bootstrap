# Plural Bootstrap Repository

Welcome to the Plural Bootstrap Repository! This repository provides the core Terraform and Kubernetes setup code used to bootstrap a Plural management cluster, enabling you to quickly set up a GitOps-driven Kubernetes environment maintained by your DevOps team.

This documentation will guide you through the architecture, folder structure, and usage conventions to help you get started efficiently and extend your infrastructure as needed.

This repo defines the core terraform code needed to bootstrap a Plural management cluster and set up your GitOps environment using Plural.  It is intended to be cloned in a users infra repo and then owned by their DevOps team from there.  We do our best to adhere to the standard terraform setup for k8s within the respective cloud, while also installing necessary add-ons as needed (eg load balancer controller and autoscaler for AWS).

> [!TIP]
> If you want a guided walkthrough of how to use your new repo and get started with a Plural-based GitOps workflow, our [how-to guide](https://docs.plural.sh/how-to) is an amazing place to start!


## General Architecture

The bootstrap environment established by this repo includes three primary components:


There are three main resources created by these templates:

* VPC Network to house all resources in the respective cloud
* K8s Control Plane + minimal worker node set
* Postgres DB (will be used for your Plural Console instance)

Our defaults are meant to be tweaked, feel free to reference the documentation of the underlying modules if you want to make a cluster private, or modify our CIDR range defaults if you want to VPC peer.

If you need additional customization, the modular terraform code and Helm charts provided within this repo can be extended or replaced as required for your specific needs.


## Installation Repo Folder Structure

A plural installation repo will have a folder structure like this:

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

You're free to extend this as you'd like, although if you use the Plural marketplace that structure will be expected.  You can also deploy services with manifests from other repositories. This repository aims to define core infrastructure and get you started in a solid, maintainable way.

## Using the Plural Catalog

The Plural Catalog operationalizes common Kubernetes infrastructure operations via a service catalog, synced through `bootstrap/catalogs.yaml`.

For example, setting up a new Kubernetes fleet can be done as follows:

1. Go to {your-console-url}/self-service/catalogs, and click the `infra` catalog.
2. Choose the `cluster-fleet-creator` PR automation and provide the necessary values.
3. Click create PR with a descriptive branch name. Once merged, this will set up dev and prod clusters using the networking defined by the core-infra stack.

Other useful self-service setups in the catalog include:

* Data infrastructure (dagster, airbyte, mlflow).
* Security tooling (trivy operator, opa gatekeeper).
* DevOps tools (elasticsearch log aggregation, victoriametrics scale-out prometheus, grafana, etc.).

Many of the common operations you'll need to do to manage your kubernetes infrastructure have all been operationalized as part of the service catalog that's synced via `bootstrap/catalogs.yaml`.  A decent example here would be setting up a new kubernetes fleet, which you can do with the following:

1. Go to {your-console-url}/self-service/catalogs, and click the `infra` catalog
2. Chose the `cluster-fleet-creator` pr automation, and fill out the needed values
3. Click create pr after filling out a decent branch name, the generated pr once merged should set up a dev and prod cluster in the networks defined by the core-infra stack we provision by default.

There are also other useful self-service setups in our catalog including:

* data infrastructure - sets up dagster, airbyte, mlflow
* security tooling - trivy operator, opa gatekeeper
* devops tools - elasticsearch log aggregation, victoriametrics based scale-out prometheus, grafana, etc.

## Adding a Workload Cluster to Your Fleet

There are many ways to set up a workload cluster.  We've given you some baseline terraform to work from in the `terraform/modules/clusters` folders.  You can easily deploy these using stacks documented [here](https://docs.plural.sh/stacks/overview).

We've actually also set this up for you via a PR automation, which you can find at the `/pr/automations` url in your newly created console.  This will trigger a PR with the follownig resources:

* `InfrastructureStack` to create the underlying physical cluster
* `Cluster` to reference that cluster via CRD and enable future crds to point to it for `ServiceDeployment` and so forth.

If you chose to create a cluster using your own automation, adding a cluster can be done simply with the `plural` cli using:

```sh
plural cd clusters boottrap --name {name}
```

or with our terraform provider, which can easily be duplicated by looking at `terraform/modules/clusters/aws/plural.tf`.

To reference a cluster in other GitOps resources, add a `Cluster` CRD like so:

To reference it in other GitOps resources, add a `Cluster` CRD like:

```yaml
apiVersion: deployments.plural.sh/v1alpha1
kind: Cluster
metadata:
  name: <name>
spec:
  handle: <name> # must be set to reference the cluster
  tags:
    some: tag # if you want to add tags to the cluster
  metadata:
    arbitrary:
      yaml: metadata # any arbitrary metadata you might want to add for service templating (see https://docs.plural.sh/deployments/templating)
```

## Installing Low-Level Kubernetes Operators

Plural provides various tools for fleet-wide deployment of critical Kubernetes add-ons. For operators like cert-manager or Istio, we recommend using the `GlobalService` resource.

See more details in the [GlobalService documentation](https://docs.plural.sh/deployments/operator/global-service).

Plural provides a number of very useful tools for fleet-wide deployment. If you need to install operators like cert-manager or Istio, we'd recommend using our `GlobalService` resource.  You can find more documentation about [here](https://docs.plural.sh/deployments/operator/global-service).

Here's an example for deploying externaldns:

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

To see a number of working examples, review your `bootstrap/o11y` or `bootstrap/network` folders. These include preconfigured global services for runtime-level Kubernetes concerns common to many clusters. If desired, you can reverse this default setup by removing corresponding manifests and pushing the changes.
