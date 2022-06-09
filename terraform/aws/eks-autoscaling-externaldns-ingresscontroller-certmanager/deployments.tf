# Get EKS cluster info to configure Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

data "aws_route53_zone" "base_domain" {
    name = var.dns_base_domain
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

    external_dns_template_vars = {
        external_dns_base_domain = var.dns_base_domain
        external_dns_role_arn    = aws_iam_role.external_dns.arn
        external_dns_zoneid      = data.aws_route53_zone.base_domain.id
    }

    external_dns_chart_values = templatefile(
        "${path.module}/values/external-dns-values.yaml",
        local.external_dns_template_vars
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

# Initialize external-dns namespace
resource "kubernetes_namespace" "external_dns" {
    metadata {
        name = var.external_dns_namespace
    }
    depends_on = [module.eks]
}

# Initialize the ingress-controller namespace
resource "kubernetes_namespace" "ingress_controller" {
    metadata {
        name = var.ingress_controller_namespace
    }
    depends_on = [module.eks]
}

# Initialize cert-manager namespace
resource "kubernetes_namespace" "cert_manager" {
    metadata {
        name = var.cert_manager_namespace
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

# Deploy External DNS
resource "helm_release" "external_dns" {
    name       = "external-dns"
    chart      = var.external_dns_chart_name
    repository = var.external_dns_chart_repo
    version    = var.external_dns_chart_version
    namespace  = var.external_dns_namespace

    set {
        name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = aws_iam_role.external_dns.arn
        type  = "string"
    }

    values = [local.external_dns_chart_values]

    depends_on = [helm_release.cluster_issuers, aws_iam_role.external_dns]
}

# Deploy Cert-Manager
resource "helm_release" "cert_manager" {
    name       = var.cert_manager_chart_name
    chart      = var.cert_manager_chart_name
    repository = var.cert_manager_chart_repo
    version    = var.cert_manager_chart_version
    namespace  = var.cert_manager_namespace

    set {
        name  = "installCRDs"
        value = "true"
    }

    set {
        name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = aws_iam_role.cert-manager.arn
        type  = "string"
    }
    depends_on = [helm_release.ingress_controller]
}

# Deploy Cluster Issuers
resource "helm_release" "cluster_issuers" {
    name       = var.cluster_issuers_release_name
    chart      = var.cluster_issuers_chart_name
    repository = var.cluster_issuers_chart_repo
    version    = var.cluster_issuers_chart_version
    namespace  = var.cert_manager_namespace

    values = [
        file("values/cluster-issuers.yaml")
    ]

    depends_on = [helm_release.cert_manager]
}

# Deploy Ingress Controller
resource "helm_release" "ingress_controller" {
    name       = var.ingress_controller_chart_name
    chart      = "ingress-nginx"
    repository = var.ingress_controller_chart_repo
    version    = var.ingress_controller_chart_version
    dependency_update = true
    force_update = true
    namespace  = var.ingress_controller_namespace

    dynamic "set" {
        for_each = var.ingress_controller_annotations

        content {
            name  = set.key
            value = set.value
            type  = "string"
        }
    }

    depends_on = [module.eks]
}