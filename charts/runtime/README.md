# Runtime Chart

This is an omnibus chart to install a few common dependencies needed to get a web-facing app running.  Each subchart is disable-able as needed so you can deploy them independently if desired. Here's a quick inventory of all components:

* traefik - serves the `nginx` ingress class through Traefik's ingress-nginx compatible provider, so Ingresses and `nginx.ingress.kubernetes.io/*` annotations written for ingress-nginx keep working. Also autoconfigured to use NLBs in AWS which are more friendly to websockets and cheaper
* private traefik - same as above but on an internal network and providing an `internal-nginx` ingress class
* cert manager - handles cert issuance, only includes a `plural` issuer by default for managing dns issuance for onplural.sh domains
* externaldns - an externaldns daemon also only configured for managing onplural.sh domains by default

## Traefik

Both instances come from the upstream [traefik chart](https://github.com/traefik/traefik-helm-chart), `traefik-private` is an alias of it. Both only run the ingress-nginx compatible provider, the IngressRoute (CRD) and plain Ingress providers are disabled. Check the [supported annotations](https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/ingress-nginx/) if you rely on less common ingress-nginx annotations.

## Migrating from 0.x (ingress-nginx)

1.0.0 replaces ingress-nginx with Traefik. Existing installs pin `version: "0.x.x"` in `bootstrap/runtime.yaml`, so they keep ingress-nginx until they opt in. Ingress resources don't need changes, the `nginx` and `internal-nginx` ingress classes are kept.

1. In `bootstrap/runtime.yaml` set `helm.version: "1.x.x"`.
2. In `helm/runtime.yaml.liquid` rename the `ingress-nginx` key to `traefik` and `ingress-nginx-private` to `traefik-private`. The nginx-specific settings under `controller:` no longer apply and can be removed.
3. Keep the existing load balancers (and their DNS records) by adopting the old controller Services:

   ```yaml
   traefik:
     service:
       nameOverride: runtime-ingress-nginx-controller
     providers:
       kubernetesIngressNGINX:
         publishService:
           pathOverride: plural-runtime/runtime-ingress-nginx-controller
   traefik-private:
     service:
       nameOverride: runtime-ingress-nginx-private-controller
     providers:
       kubernetesIngressNGINX:
         publishService:
           pathOverride: plural-runtime/runtime-ingress-nginx-private-controller
   ```

   Without this, new load balancers are created and external-dns moves the records to them. Either way the Service switches to the Traefik pods (new ports and selector) while the ingress-nginx pods are removed, so expect a short blip and pick a quiet window.
4. On AWS the NLBs send PROXY protocol headers, so Traefik has to trust the VPC range. Add this to `helm/runtime.yaml.liquid`:

   ```yaml
   traefik:
     ports:
       web:
         proxyProtocol:
           trustedIPs:
           - {{ configuration.vpcCidr | default: '10.0.0.0/16' }}
       websecure:
         proxyProtocol:
           trustedIPs:
           - {{ configuration.vpcCidr | default: '10.0.0.0/16' }}
   traefik-private:
     ports: # same as above
   ```

   It reads `vpcCidr` from the `runtime-config` secret in the `infra` namespace and falls back to `10.0.0.0/16`, the default VPC range of `plural up`. Unlike ingress-nginx, `X-Forwarded-*` headers sent by clients are not trusted, the client IP comes from the PROXY header. If your VPC uses a different range, add it to the secret:

   ```sh
   kubectl -n infra patch secret runtime-config -p '{"stringData":{"vpcCidr":"<vpc cidr>"}}'
   ```

5. Commit and push. The deployment operator redeploys the `runtime` service with the new chart and removes the ingress-nginx resources.

## Cert Manager

We expect cert manager might be the one app here someone would want to disable and re-deploy (eg if you want to set it up via a global service or hand-configure it in other ways, eg to enable IRSA easily).  To do that simply add:

```yaml
cert-manager:
  enabled: false
```

to your config.

## ExternalDns

External dns is actually safe to run multiple times in the same cluster.  If you'd like to set up externaldns for another domain, we simply recommend you deploy another instance of it configured how you might like.
