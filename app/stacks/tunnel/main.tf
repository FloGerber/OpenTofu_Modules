locals {
  jumphost = var.environment == "production" ? "domain.net" : "x.${var.environment}.domain.net"
}

resource "null_resource" "tunnel" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "init-tunnel.sh ${local.jumphost}"
  }
}
