variable "name_prefix" {
  type        = string
  description = "Prefix to be used on each infrastructure object Name created in AWS."
  default     = "eks"
}

variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used from EKS Ingress. / External DNS"
  default    = "k8s-test.example.com"
}

# EKS Variables
variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
  default     = "k8s-test"
}

variable "cluster_version" {
  type        = string
  description = "Which EKS version of K8s to run"
  default     = "1.21"
}

# Autoscaling variables
variable "autoscaling_chart_name" {
  type        = string
  description = "Autoscaling Helm chart name."
  default     = "cluster-autoscaler"
}

variable "autoscaling_chart_repo" {
  type        = string
  description = "Autoscaling Helm repository name."
  default     = "https://kubernetes.github.io/autoscaler"
}

variable "autoscaling_chart_version" {
  type        = string
  description = "Autoscaling Helm chart version."
  default     = "9.11.0" 
}

variable "autoscaling_namespace" {
  type        = string
  description = "Autoscaling Namespace."
  default     = "autoscaler"
}

# External DNS Variables
variable "external_dns_chart_name" {
  type        = string
  description = "External DNS Helm chart name"
  default     = "external-dns"
}

variable "external_dns_chart_repo" {
  type        = string
  description = "External DNS Helm repository name"
  default     = "https://kubernetes-sigs.github.io/external-dns/"
}

variable "external_dns_chart_version" {
  type        = string
  description = "External DNS chart version"
  default     = "1.7.1"
}

variable "external_dns_namespace" {
  type        = string
  description = "External DNS namespace"
  default     = "external-dns"
}

variable "tags" {
  type = map(string)
  default = {
    owner       = "DevOps"
    managered   = "terraform" 
  }
}
# Ingress Variables
variable "ingress_controller_chart_name" {
  type        = string
  description = "Ingress Controller Helm chart name."
  default     = "ingress-nginx"
}

variable "ingress_controller_chart_repo" {
  type        = string
  description = "Ingress Controller Helm repository name."
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "ingress_controller_chart_version" {
  type        = string
  description = "Ingress Controller Helm chart version."
  default     = "3.37.0" 
}

variable "ingress_controller_annotations" {
  type        = map(string)
  description = "Ingress Controller Annotations required for EKS."
  default     = {
    "service.beta.kubernetes.io/aws-load-balancer-proxy-protocol"       = "'*'"
    "service.beta.kubernetes.io/aws-load-balancer-type"                 = "nlb"
  }
}

variable "ingress_controller_namespace" {
  type        = string
  description = "Ingress Controller Namespace."
  default     = "ingress-nginx"
}

# Cert-Manager Variables
variable "cert_manager_chart_name" {
  type        = string
  description = "Cert-Manager Helm chart name."
  default     = "cert-manager"
}

variable "cert_manager_chart_repo" {
  type        = string
  description = "Cert-Manager Helm repository name."
  default     = "https://charts.jetstack.io"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Cert-Manager Helm chart version."
  default     = "1.6.1"
}

variable "cert_manager_namespace" {
  type        = string
  description = "Cert-Manager Namespace."
  default     = "cert-manager"
}

# Cluster Issuers Variables
variable "cluster_issuers_release_name" {
  type        = string
  description = "Cluster Issuers Helm release name."
  default     = "cluster-issuers"
} 

variable "cluster_issuers_chart_name" {
  type        = string
  description = "Cluster Issuers Helm chart name."
  default     = "raw"
}

variable "cluster_issuers_chart_repo" {
  type        = string
  description = "Cluster Issuers Helm repository name"
  default     = "https://charts.helm.sh/incubator"
}

variable "cluster_issuers_chart_version" {
  type        = string
  description = "Cluster Issuers chart version"
  default     = "0.2.3"
}
