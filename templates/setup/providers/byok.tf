// BYOK – the cluster already exists externally, so the mgmt module is just a
// stub that provides the outputs expected by console.tf without provisioning anything.
module "mgmt" {
  source = "./cluster"
  db_url = "{{ .Context.DbUrl }}"
}

