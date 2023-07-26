resource "openstack_blockstorage_volume_v3" "db_backup" {
  region      = var.region[var.datacenter]
  name        = "db-backup"
  description = "Volume for storing db backups"
  size        = 20
}

resource "openstack_compute_volume_attach_v2" "db_backup" {
  instance_id = openstack_compute_instance_v2.db_backup.id
  volume_id   = openstack_blockstorage_volume_v3.db_backup.id
}
