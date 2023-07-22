# terraform-aws-eks-irsa

## Description
IAM Roles for Service Accounts (IRSA) is a feature in Amazon EKS that lets you associate an AWS IAM role with a Kubernetes service account. This provides granular permissions to AWS services for the pods associated with the service account, improving security by avoiding the need to use a node's IAM role or share IAM credentials. This also simplifies permission management and reduces the risk of privilege escalation.

## How to configurate

### Step 1: Install and Configure IRSA on AWS

You need to identify `k8s_namespace` and `k8s_service_account` On EKS beforehand, which you want to integrate with IAM Roles for Service Accounts.    

Then you must define what `json_policy` is needed for your application to integrate with AWS.


```hcl
variable "aws_region" {
  description = "Please enter the region used to deploy this infrastructure"
  type        = string
  default = "us-west-2"  
}

variable "cluster_id" {
  description = "Enter full name of EKS Cluster"
  type        = string
  default = "<Full Name EKS Cluster>" 
}

#Load informations of your EKS cluster
data "aws_eks_cluster" "eks_k8s" {
  name = var.cluster_id
}


module "eks-irsa" {
  source  = "mrnim94/eks-irsa/aws"
  version = "0.0.4"

  aws_region = var.aws_region
  environment = "dev"
  business_divsion = "irsa-zeus-rotations"

  k8s_namespace = "kube-system"
  k8s_service_account = "zeus-rotations"
  json_policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateAccessKey",
        "iam:ListAccessKeys",
        "iam:DeleteAccessKey"
      ],
      "Resource": "*"
    }
  ]
}
EOT

  aws_iam_openid_connect_provider_arn = "arn:aws:iam::${element(split(":", "${data.aws_eks_cluster.eks_k8s.arn}"), 4)}:oidc-provider/${element(split("//", "${data.aws_eks_cluster.eks_k8s.identity[0].oidc[0].issuer}"), 1)}"
}

output "irsa_iam_role_arn" {
  description = "aws_iam_openid_connect_provider_arn"
  value = module.eks-irsa.irsa_iam_role_arn
}
```