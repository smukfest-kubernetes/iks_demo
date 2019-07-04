variable "cluster_name" {
  default = "terraform-env-azcluster"
}

# The datacenter of the worker nodes
variable "cluster_datacenter" {
  description = "CLI: ibmcloud ks locations"
  default     = "fra02"
}

variable "cluster_machine_type" {
  description = "CLI: ibmcloud ks machine-types <datacenter>"
  default     = "u2c.2x4"
}

variable "cluster_worker_num" {
  default = "1"
}

variable "az1" {
    default = "fra02"
}

variable "az1_vlan_id_public" {
  description = "CLI: ibmcloud ks vlans <datacenter>"
  default     = "1898"
}

variable "az1_vlan_id_private" {
  description = "CLI: ibmcloud ks vlans <datacenter>"
  default     = "1817"
}

variable "az2" {
    default = "fra04"
}

variable "az2_vlan_id_public" {
  description = "CLI: ibmcloud ks vlans <datacenter>"
  default     = "842"
}

variable "az2_vlan_id_private" {
  default     = "862"
}
variable "az3" {
    default = "fra05"
}

variable "az3_vlan_id_public" {
  default     = "830"
}

variable "az3_vlan_id_private" {
  default     = "837"
}
variable "cluster_hardware" {
  description = "Shared, Dedicated or Bare Metal"
  default     = "shared"
}

# The desired Kubernetes version of the created cluster.
# If present, at least major.minor must be specified.
variable "cluster_kube_version" {
  description = "CLI: ibmcloud ks kube-versions"
  default     = "1.13.5"
}

resource "ibm_container_cluster" "azcluster" {
  name              = "${var.cluster_name}"
  datacenter        = "${var.cluster_datacenter}"
  hardware          = "shared"
  machine_type      = "${var.cluster_machine_type}"
  region            = "${var.ibmcloud_region}"
  kube_version      = "${var.cluster_kube_version}"
  public_vlan_id    = "${var.az1_vlan_id_public}"
  private_vlan_id   = "${var.az1_vlan_id_private}"
  resource_group_id = "${data.ibm_resource_group.group.id}"
  # default_pool_size = 1
}

resource "ibm_container_worker_pool" "test_pool" {
  cluster          = "${ibm_container_cluster.azcluster.id}"
  worker_pool_name = "default"
  machine_type     = "u2c.2x4"
  size_per_zone    = 1
  hardware         = "shared"
  disk_encryption  = "true"
  region           = "${var.ibmcloud_region}"
  labels = {
    "test" = "test-pool"
    "test1" = "test-pool1"
  }
}

resource ibm_container_worker_pool_zone_attachment az1 {
  # cluster         = "${var.environment_name}-azcluster"
  cluster           = "${ibm_container_cluster.azcluster.id}"
  worker_pool       = "${element(split("/",ibm_container_worker_pool.test_pool.id),1)}"
  zone              = "${var.az1}"
  public_vlan_id    = "${var.az1_vlan_id_public}"
  private_vlan_id   = "${var.az1_vlan_id_private}"
  region            = "${var.ibmcloud_region}"
  resource_group_id = "${data.ibm_resource_group.group.id}"
}
resource ibm_container_worker_pool_zone_attachment az2 {
  # cluster         = "${var.environment_name}-azcluster"
  cluster           = "${ibm_container_cluster.azcluster.id}"
  worker_pool       = "${element(split("/",ibm_container_worker_pool.test_pool.id),1)}"
  zone              = "${var.az2}"
  public_vlan_id    = "${var.az2_vlan_id_public}"
  private_vlan_id   = "${var.az2_vlan_id_private}"
  region            = "${var.ibmcloud_region}"
  resource_group_id = "${data.ibm_resource_group.group.id}"
  depends_on        = ["ibm_container_worker_pool_zone_attachment.az1"]
}
resource ibm_container_worker_pool_zone_attachment az3 {
  # cluster         = "${var.environment_name}-azcluster"
  cluster           = "${ibm_container_cluster.azcluster.id}"
  worker_pool       = "${element(split("/",ibm_container_worker_pool.test_pool.id),1)}"
  zone              = "${var.az3}"
  public_vlan_id    = "${var.az3_vlan_id_public}"
  private_vlan_id   = "${var.az3_vlan_id_private}"
  region            = "${var.ibmcloud_region}"
  resource_group_id = "${data.ibm_resource_group.group.id}"
  depends_on        = ["ibm_container_worker_pool_zone_attachment.az2"]

  //User can increase timeouts
  # timeouts {
  #     create = "90m"
  #     update = "3h"
  #     delete = "30m"
  #   }
}