## PRE-RELEASE NOTES
* Uncomment `vultr-csi.yml` source in `vultr-data.tf`
* Change `vultr-csi.yml` file source in `vultr-controllers.tf` to content from data source
* Remove `files/vultr-csi-latest.yml`

#### Usage:
1. Export your Vultr API Keys as an environment variable:
```
$ export VULTR_API_KEY=EXAMPLEAPIKEYABCXYZ
$ export TF_VAR_cluster_api_key=ANOTHEREXAMPLEAPIKEYABCXYZ # You can re-use your Terraform API key, however I prefer a separate Kubernetes sub-user API Key.
```
2. Create `main.tf` file and `cluster_api_key` variable with the following(adjust parameters as necessary). 
```
# main.tf
variable "cluster_api_key" {
  type = string
}

module "cluster" {
  source          = "git::https://github.com/vultr/terraform-kubernetes-vultr?ref=centos"

  cluster_api_key          = var.cluster_api_key                       
  cluster_name             = "cluster-name"
}
```
3. Deploy the cluster
```
$ terraform init
$ terraform validate
$ terraform apply
```

#### Optional module parameters and defaults:
```
vultr_ccm_release  - default: "latest" (If specifying a version use the form `vX.Y.Z`)
vultr_csi_release  - default: "latest" (If specifying a version use the form `vX.Y.Z`)
cluster_cni        - default: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
controller_count   - default: 1 (HA not yet supported)
worker_count       - default: 3
controller_plan    - default: "8192 MB RAM,160 GB SSD,4.00 TB BW"
worker_plan        - default: "4096 MB RAM,80 GB SSD,3.00 TB BW"
cluster_region     - default: "New Jersey" (Block Storage is currently only available in New Jersey)
cluster_os         - default: "CentOS 7 x64" (Should only test new releases of CentOS if using the "centos" branch, not other linux distros)
k8_release         - default: "v1.17.4"
docker_release     - default: "19.03.4"
containerd_release - default: "1.2.10"
pod_network_cidr   - default: "10.244.0.0/16" (Should change if changing `cluster_cni`) 
```


                
