################################################################################
# aws-auth configmap
# Only EKS managed node groups automatically add roles to aws-auth configmap
# so we need to ensure fargate profiles and self-managed node roles are added
################################################################################

data "aws_eks_cluster_auth" "this" {
    name = module.eks.cluster_id
}

locals {
    kubeconfig = yamlencode({
        apiVersion      = "v1"
        kind            = "Config"
        current-context = "terraform"
        clusters = [{
        name = module.eks.cluster_id
        cluster = {
            certificate-authority-data = module.eks.cluster_certificate_authority_data
            server                     = module.eks.cluster_endpoint
        }
        }]
        contexts = [{
        name = "terraform"
        context = {
            cluster = module.eks.cluster_id
            user    = "terraform"
        }
        }]
        users = [{
        name = "terraform"
        user = {
            token = data.aws_eks_cluster_auth.this.token
        }
        }]
    })
}

resource "null_resource" "patch" {
    triggers = {
        kubeconfig = base64encode(local.kubeconfig)
        cmd_patch  = "kubectl patch configmap/aws-auth --patch \"${module.eks.aws_auth_configmap_yaml}\" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
    }

    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        environment = {
        KUBECONFIG = self.triggers.kubeconfig
        }
        command = self.triggers.cmd_patch
    }
}