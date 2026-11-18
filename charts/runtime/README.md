# Runtime Chart

This is an omnibus chart to install a few common dependencies needed to get a web-facing app running.  Each subchart is disable-able as needed so you can deploy them independently if desired. Here's a quick inventory of all components:

* ingress nginx - adds a basic `nginx` ingress class, also autoconfigured to use NLBs in AWS which are more friendly to websockets and cheaper
* private ingress nginx - same as above but on an internal network and providing an `internal-nginx` ingress class
* cert manager - handles cert issuance, only includes a `plural` issuer by default for managing dns issuance for onplural.sh domains
* externaldns - an externaldns daemon also only configured for managing onplural.sh domains by default

## Cert Manager

We expect cert manager might be the one app here someone would want to disable and re-deploy (eg if you want to set it up via a global service or hand-configure it in other ways, eg to enable IRSA easily).  To do that simply add:

```yaml
cert-manager:
  enabled: false
```

to your config.

## ExternalDns

External dns is actually safe to run multiple times in the same cluster.  If you'd like to set up externaldns for another domain, we simply recommend you deploy another instance of it configured how you might like.

## Gatekeeper ownership

Gatekeeper is not packaged by this runtime chart: it has no Gatekeeper dependency or templates. Manage Gatekeeper version changes through the service that owns its installation rather than adding it to runtime.
