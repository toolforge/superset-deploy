resource "openstack_db_instance_v1" "superset" {
  region    = var.region[var.datacenter]
  name      = "superset-tf"
  flavor_id = "bb8bee7e-d8f9-460b-8344-74f745c139b9"
  size      = 4

  network {
    uuid = "7425e328-560c-4f00-8e99-706f3fb90bb4"
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
