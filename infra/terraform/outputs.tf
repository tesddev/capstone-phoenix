output "control_plane_public_ip" {
  description = "Public IP of the k3s control-plane node."
  value       = module.compute.control_plane_public_ip
}

output "control_plane_private_ip" {
  description = "Private IP of the k3s control-plane node."
  value       = module.compute.control_plane_private_ip
}

output "worker_public_ips" {
  description = "Public IPs of worker nodes."
  value       = module.compute.worker_public_ips
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes."
  value       = module.compute.worker_private_ips
}

output "node_inventory" {
  description = "Structured node inventory for Ansible."
  value = {
    control_plane = {
      name       = "cp-1"
      public_ip  = module.compute.control_plane_public_ip
      private_ip = module.compute.control_plane_private_ip
    }
    workers = [
      for idx, public_ip in module.compute.worker_public_ips : {
        name       = "worker-${idx + 1}"
        public_ip  = public_ip
        private_ip = module.compute.worker_private_ips[idx]
      }
    ]
  }
}
