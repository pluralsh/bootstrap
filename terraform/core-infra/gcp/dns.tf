data "google_dns_managed_zone" "prod" {
  name    = "{{ .Context.ManagedZone }}"
  project = "{{ .Project }}"
}

resource "google_dns_managed_zone" "dev" {
  name        = "{{ replace "." "-" (printf "dev.%s" .AppDomain) }}"
  dns_name    = "dev.{{ .AppDomain }}."
  project     = "{{ .Project }}"
  description = "Dev zone for {{ .AppDomain }}"
}

resource "google_dns_record_set" "dev_ns" {
  name         = "dev.{{ .AppDomain }}."
  managed_zone = data.google_dns_managed_zone.prod.name
  project      = data.google_dns_managed_zone.prod.project
  type         = "NS"
  ttl          = 30
  rrdatas      = google_dns_managed_zone.dev.name_servers
}
