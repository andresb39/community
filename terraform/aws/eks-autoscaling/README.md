# Terraform EKS Autoscaling

## TODO
**Stage 1**
- [X] We Install and Manage EKS with Terraform
- [X] We also use Terraform for Cluster Addons Autoscaling


## Requirements

### Tools
- [awscli](https://aws.amazon.com/cli/)
- [terraform](https://www.terraform.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
- [helm](https://helm.sh/docs/intro/install/)

### Terraform

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 4.8.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | = 2.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | = 2.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.8.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.5.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.9.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 18.17.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.autoscaler](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.autoscaler](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy) | resource |
| [aws_key_pair.kp](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/key_pair) | resource |
| [aws_kms_key.ebs](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/kms_key) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/kms_key) | resource |
| [aws_security_group.additional](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/security_group) | resource |
| [aws_security_group.remote_access](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/security_group) | resource |
| [helm_release.autoscaling](https://registry.terraform.io/providers/hashicorp/helm/2.5.0/docs/resources/release) | resource |
| [kubernetes_namespace.autoscaling](https://registry.terraform.io/providers/hashicorp/kubernetes/2.9.0/docs/resources/namespace) | resource |
| [null_resource.oidc](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.patch](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.pk](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.ebs](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_chart_name"></a> [autoscaling\_chart\_name](#input\_autoscaling\_chart\_name) | Autoscaling Helm chart name. | `string` | `"cluster-autoscaler"` | no |
| <a name="input_autoscaling_chart_repo"></a> [autoscaling\_chart\_repo](#input\_autoscaling\_chart\_repo) | Autoscaling Helm repository name. | `string` | `"https://kubernetes.github.io/autoscaler"` | no |
| <a name="input_autoscaling_chart_version"></a> [autoscaling\_chart\_version](#input\_autoscaling\_chart\_version) | Autoscaling Helm chart version. | `string` | `"9.11.0"` | no |
| <a name="input_autoscaling_namespace"></a> [autoscaling\_namespace](#input\_autoscaling\_namespace) | Autoscaling Namespace. | `string` | `"autoscaler"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name. | `string` | `"k8s-test"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Which EKS version of K8s to run | `string` | `"1.21"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to be used on each infrastructure object Name created in AWS. | `string` | `"eks"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | <pre>{<br>  "managered": "terraform",<br>  "owner": "DevOps"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_configmap_yaml"></a> [aws\_auth\_configmap\_yaml](#output\_aws\_auth\_configmap\_yaml) | Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of attribute maps for all EKS cluster addons enabled |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | IAM role ARN of the EKS cluster |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | IAM role name of the EKS cluster |
| <a name="output_cluster_iam_role_unique_id"></a> [cluster\_iam\_role\_unique\_id](#output\_cluster\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| <a name="output_cluster_identity_providers"></a> [cluster\_identity\_providers](#output\_cluster\_identity\_providers) | Map of attribute maps for all EKS identity providers enabled |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster for the OpenID Connect identity provider |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | Platform version for the cluster |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| <a name="output_cluster_security_group_arn"></a> [cluster\_security\_group\_arn](#output\_cluster\_security\_group\_arn) | Amazon Resource Name (ARN) of the cluster security group |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID of the cluster security group |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | Map of attribute maps for all EKS managed node groups created |
| <a name="output_node_security_group_arn"></a> [node\_security\_group\_arn](#output\_node\_security\_group\_arn) | Amazon Resource Name (ARN) of the node shared security group |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | ID of the node shared security group |
| <a name="output_oidc_provider"></a> [oidc\_provider](#output\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading `https://`) |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true` |
