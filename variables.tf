variable "vultr_ccm_release" {
  type    = string
  default = "latest"
}

variable "vultr_csi_release" {
  type    = string
  default = "latest"
}

variable "cluster_api_key" {
  type = string
}

variable "cluster_cni" {
  type = string
  default = "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
}

variable "cluster_name" {
  type = string
}

variable "controller_count" {
  type    = number
  default = 1
}

variable "worker_count" {
  type    = number
  default = 3
}

variable "controller_plan" {
  type    = string
  default = "8192 MB RAM,160 GB SSD,4.00 TB BW"
}

variable "worker_plan" {
  type    = string
  default = "4096 MB RAM,80 GB SSD,3.00 TB BW"
}

variable "cluster_region" {
  type    = string
  default = "New Jersey"
}

variable "cluster_os" {
  type    = string
  default = "CentOS 7 x64"
}

variable "k8_release" {
  type    = string
  default = "v1.17.4"
}

variable "docker_release" {
  type    = string
  default = "19.03.4"
}

variable "containerd_release" {
  type    = string
  default = "1.2.10"
}

variable "pod_network_cidr" {
  type    = string
  default = "10.244.0.0/16" 
}
