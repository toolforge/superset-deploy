resource "openstack_db_instance_v1" "superset" {
  region    = var.region[var.datacenter]
  name      = "superset${var.name[var.datacenter]}"
  flavor_id = var.db_flavor_uuid[var.datacenter]
  size      = var.db_size[var.datacenter]

  network {
    uuid = var.network_uuid[var.datacenter]
  }

  user {
    name      = "superset"
    host      = "%"
    password  = var.db_password[var.datacenter]
    databases = ["superset"]
  }

  database {
    name = "superset"
  }

  datastore {
    version = "5.7.29"
    type    = "mysql"
  }
}
