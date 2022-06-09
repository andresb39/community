# OIDC URL
locals {
  oidc_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

# Get the current user
data "aws_caller_identity" "current" {}


# Role for AutoScaling 
resource "aws_iam_role" "autoscaler" {
  name  = "${module.eks.cluster_id}-autoscaler"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_url}:sub": "system:serviceaccount:autoscaler:autoscaler"
        }
      }
    }
  ]
}
EOF
}

# Policy attached to the role
resource "aws_iam_role_policy" "autoscaler" {
  name_prefix = "${module.eks.cluster_id}-autoscaler"
  role        = aws_iam_role.autoscaler.name
  policy      = file("${path.module}/policy/autoscaler-policy.json")
}

# Exrternal-DNS
resource "aws_iam_role" "external_dns" {
  name  = "${module.eks.cluster_id}-external-dns"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_url}:sub": "system:serviceaccount:external-dns:external-dns"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "external_dns" {
  name_prefix = "${module.eks.cluster_id}-external-dns"
  role        = aws_iam_role.external_dns.name
  policy      = file("${path.module}/policy/external-dns-policy.json")
}

# Cert-Manager
resource "aws_iam_role" "cert-manager" {
  name  = "${module.eks.cluster_id}-cert-manager"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_url}:sub": "system:serviceaccount:cert-manager:cert-manager"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cert-manager" {
  name_prefix = "${module.eks.cluster_id}-cert-manager"
  role        = aws_iam_role.cert-manager.name
  policy      = file("${path.module}/policy/cert-manager-policy.json")
}
