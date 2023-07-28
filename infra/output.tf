output "app_ssh_command" {
  value = "ssh ${local.app_admin}@${module.vm_app.public_ip_address}"
}

output "agent_ssh_command" {
  value = "ssh ${local.agent_admin}@${module.vm_agent.public_ip_address}"
}
