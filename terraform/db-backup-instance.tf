data "openstack_images_image_v2" "debian" {
  most_recent = true
  name        = "debian-12.0-bookworm"
}

resource "openstack_blockstorage_volume_v3" "db_backup" {
  region      = var.region[var.datacenter]
  name        = "db-backup"
  description = "Volume for storing db backups"
  size        = 20
}

resource "openstack_compute_instance_v2" "db_backup" {
  name      = "db-backup"
  image_id  = data.openstack_images_image_v2.debian.id
  flavor_id = "bb8bee7e-d8f9-460b-8344-74f745c139b9" # update to lookup?

  network {
    name = "lan-flat-cloudinstances2b"
  }
}

resource "openstack_compute_volume_attach_v2" "db_backup" {
  instance_id = openstack_compute_instance_v2.db_backup.id
  volume_id   = openstack_blockstorage_volume_v3.db_backup.id
}
