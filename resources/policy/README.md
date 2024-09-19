# Policy Setup

This guide should give you a full setup for OPA Gatekeeper and bundles to enforce or validate common Kubernetes policy benchmarks your org might be interested in enforcing.  The setup is pretty simple, self-contained in the `/services` folder.  You might want to slightly tweak it for a few reasons:

* only want to setup policy enforcement on a subset of your fleet (it's fleet-wide by default)
* prefer to chose a different policy bundle, our default setup points to the `cis-k8s-v1.5.1` one
* tweaking namespace names, crd names, etc for your org's preferences

## Adopting This Setup

We'd generally recommend vendoring this into a repo your org owns, and rewiring the crds to point to that repo as appropriate.  This will make it easier for you to evolve the policy setup to your needs and not be reliant entirely on Plural to push updates.

The main areas you'd likely need to customize are:

* `services/bundle.yaml` - if you'd like to opt into a policy bundle or modify the bundle to use
* `policyies/bundles/*` - all policies are configured to dryrun enforcement by default, that can be changed to warn or deny depending on your strictness levels