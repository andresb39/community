# Get EKS cluster info to configure Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

# We need to define some locals to be used later on for External DNS
locals {
    autoscaler_template_vars = {
        cluster_name = var.cluster_name
        autoscaler_role_arn = aws_iam_role.autoscaler.arn
    }
    autoscaler_chart_values = templatefile(
        "${path.module}/values/autoscaler-values.yaml",
        local.autoscaler_template_vars
    )
}

# Get EKS authentication to manage k8s objects
provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
}

# Initialize the autoscaling namespace
resource "kubernetes_namespace" "autoscaling" {
    metadata {
        name = var.autoscaling_namespace
    }
    depends_on = [module.eks]
}



provider "helm" {
    kubernetes {
        host                   = data.aws_eks_cluster.cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
        token                  = data.aws_eks_cluster_auth.cluster.token
    }
}

# Deploy Autoscaling
resource "helm_release" "autoscaling" {
    name       = var.autoscaling_chart_name
    chart      = var.autoscaling_chart_name
    repository = var.autoscaling_chart_repo
    version    = var.autoscaling_chart_version
    dependency_update = true
    force_update = true
    namespace  = var.autoscaling_namespace
    values = [local.autoscaler_chart_values]
    depends_on = [module.eks]
}
