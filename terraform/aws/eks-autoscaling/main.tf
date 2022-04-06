
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.17.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    capacity_type  = "SPOT"
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    worker = {
      name = "eks-worker"
      use_name_prefix = true

      create_launch_template = false
      launch_template_name   = ""

      min_size     = 1
      max_size     = 7
      desired_size = 1

      remote_access = {
        ec2_ssh_key               = aws_key_pair.kp.key_name
        source_security_group_ids = [aws_security_group.remote_access.id]
      }

      enable_bootstrap_user_data = true
      bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=100'"

      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT

      post_bootstrap_user_data = <<-EOT
      cd /tmp
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl enable amazon-ssm-agent
      sudo systemctl start amazon-ssm-agent
      EOT

      disk_size            = 50
      force_update_version = true
      labels = {
        nodegroup = "infrastructure"
      }

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      description = "EKS managed node group"

      ebs_optimized           = true
      
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = aws_kms_key.ebs.arn
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-worker"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group worker"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
      ]

      create_security_group          = true
      security_group_name            = "eks-managed-node-group-worker"
      security_group_use_name_prefix = false
      security_group_description     = "EKS managed node group worker"
      security_group_tags             = {
        Purpose = "Protector of the kubelet"
      }

      tags = {
        ExtraTag = "EKS managed node group worker"
      }

    }
  }
  tags = var.tags
}

# You must have the eksctl tool installed before 
resource "null_resource" "oidc" {
  provisioner "local-exec" { 
    command = "eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster ${var.cluster_name} --approve"  
  }
  depends_on = [module.eks]
}