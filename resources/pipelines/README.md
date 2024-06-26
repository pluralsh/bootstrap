# Pipelines Demo

This is a very trivial demo to show a simple helm chart pipeline, it has a few main components:

* wrapper service that would point to the `/services` directory that will sync everything in
* service under `/dev` with a service deployment CRD and global service CRD to set up a global service for your dev tier. Note the tags for the GlobalService CRD there.
* service under `/prod` with a service deployment CRD and global service CRD to set up a global service for your prod tier.  Note the tags for the GlobalService CRD there.
* service under `/pipeline` that configures the pipelines CRDs needed to automate promotion between them.

The dev service sets up a deployment for all clusters in the dev tier of the fleet, any updates to that subfolder will propagate there.  Similarly for the prod service.  This is configured to be manually git-ops'ed, so you'll have to specify all changes in this repo.

Note this uses a git-vendored helm chart to make things as flexible as possible.  This approach is perfectly compatible w/ sourcing charts from helm repositories defined as Flux `HelmRepository` crds as well, and our docs should show an example of that as well.

## The Pipeline

The pipeline is designed to be PR-driven to maintain GitOps purity.  This involves a Pipeline CRD defining the pipeline, where each stage points to a PRAutomation as its promotion criteria, and a PipelineContext.  To trigger the pipeline, you can simply modify `spec.context` w/in the PipelineContext, and once the CRD is synced, it'll start initiating the necessary PR's.

## Setting It Up Yourself

TLDR, fork or add this repo to your console and then create a service named `pipeline-demo` under the `infra` namespace in your management cluster, pointing to the `/services` subfolder.

If you might need to be delicate about namespace creation, just grep for `namespace:` for all the namespaces used and create them manually.  You should also create the `gh-test` ScmConnection in your console manually, or rewire it to an existing one in the `pipeline/prautomation.yaml` file's `scmConnectionRef` field.

`dev/podinfo.yaml` and `prod/podinfo.yaml` are currently wired to `k3s-test` by default.  Just switch that name to a cluster you already have, and potentially you might need to create the `Cluster` crds for them, eg:

```yaml
apiVersion: deployments.plural.sh/v1alpha1
kind: Cluster
metadata:
  name: k3s-test
  namespace: infra
spec:
  handle: k3s-test
```

We've already created those in `services/clusters.yaml` but you're free to rename or remove them.

## Setting up a test fleet

One easy way to test this out is to use a few local k3d clusters. k3d is a version of k3s meant to run entirely in docker, and is a bit more feature-rich than KIND.  The process to set it up is simple, you'll first want to install k3d here: https://k3d.io/v5.6.0/#releases, then we've added a small make file with targets to create a cluster and install an agent easily.  You'll first want to run:

```sh
make login
```

That will log in your Plural CLI to the console (go to `/profile/access-tokens` to create a token).  Then your can run:

```sh
make setup-k3s
```

To create a new named k3s cluster.  If for whatever reason you fail to install the agent properly, you can always redrive the installation with `plural cd clusters reinstall {cluster-name}`

## Notifications Setup

We also added a commented setup for notifications routing in `services/notifications.yaml`, it expects you to have already created a notification sink named `slack`, which can be done in the notifications tab of the console UI most easily.