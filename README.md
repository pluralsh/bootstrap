# Plural Bootstrap

This repo defines the core terraform code needed to bootstrap a Plural management cluster.  It is intended to be cloned in a users infra repo and then owned by their DevOps team from there.  We do our best to adhere to the standard terraform setup for k8s within the respective cloud, while also installing necessary add-ons as needed (eg load balancer controller and autoscaler for AWS).

## General Architecture

There are three main resources created by these templates:

* VPC Network to house all resources in the respective cloud
* K8s Control Plane + minimal worker node set
* Postgres DB (will be used for your Plural Console instance)

Our defaults are meant to be tweaked, feel free to reference the documentation of the underlying modules if you want to make a cluster private, or modify our CIDR range defaults if you want to VPC peer.

When used in a plural installation repo, the process is basically:

* create a git submodule in the installation repo pointing to the https://github.com/pluralsh/bootstrap.git repository
* template and copy base terraform files into their respective folders (`/clusters` for cluster infra and `/apps` for app setup)
* execute the terraform in sequence from there

THis follows a generate-once approach, as in we'll generate the working defaults and any customizations from there are left to the user.  This makes it much easier to reimplement our setup for a company's security or scalability preferences rather than worrying about an upstream change.  If you ever want to sync from upstream, you can simply `cd bootstrap && git pull` to fetch the most recent changes.

## Installation repo folder structure

A plural installation repo will have a folder structure like this:

```
helm-values/ # git crypted helm values to be used for app installs
- ${app}.yaml # value overrides
- ${app}-defaults.yaml # default values we generate on install

setup/ # setup for apps within your cluster fleet, this is the root service-of-services that bootstraps everything recursively

terraform/
  - mgmt # module for setting up your management cluster
  - modules
  - - clusters
  - - - {cloud} # we've crafted some reusable modules for setting up clusters on most major clouds, feel free to use these in stacks or wherever
  - ${app}/ - submodule for individual app's terraform
```

You're free to extend this as you'd like, although if you use the plural marketplace that structure will be expected.  You can also deploy services w/ manifests in other repos, this is meant to serve as a base to define the core infrastructure and get you started in a sane way.

## Add a workload cluster to your fleet

There are many ways to set up a workload cluster.  We've given you some baseline terraform to work from in the `terraform/modules/clusters` folders.  You can easily deploy these using stacks documented [here](https://docs.plural.sh/stacks/overview).

We've actually also set this up for you via a PR automation, which you can find at the `/pr/automations` url in your newly created console.  This will trigger a PR with the follownig resources:

* `InfrastructureStack` to create the underlying physical cluster
* `Cluster` to reference that cluster via CRD and enable future crds to point to it for `ServiceDeployment` and so forth.

If you chose to create a cluster using your own automation, adding a cluster can be done simply with the `plural` cli using:

```sh
plural cd clusters boottrap --name {name}
```

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

## Installing Low-Level K8s Operators

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

## Fleet Setup

There's a few common things you'll often need to solve when managing kubernetes.  We've collected a lot of tested setups that you can adapt into your own environments.  In particular, we've provided resources for setting up:

* monitoring - full loki + prometheus agent setup and how to connect them both to your instance of the console
* OPA policy management - example yaml setup for OPA Gatekeeper and various constraints to meet common important benchmarks.
* pipelines - a full PR Automation pipeline setup inclusive of using global services as well that should help testdrive some of the more advanced change management capabilities of the platform.