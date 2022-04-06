variable "name_prefix" {
  type        = string
  description = "Prefix to be used on each infrastructure object Name created in AWS."
  default     = "eks"
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

variable "tags" {
  type = map(string)
  default = {
    owner       = "DevOps"
    managered   = "terraform" 
  }
}