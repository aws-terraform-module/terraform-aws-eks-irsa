# Input Variables - Placeholder file
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-west-2"  
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "staging"
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "argo-workflow-nim"
}

# Business Division
variable "eks_cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  type = string
  default = "staging-nim-engines"
}

variable "aws_iam_openid_connect_provider_arn" {
  description = "The ARN assigned by AWS for this provider/data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn"
  type = string
  default = ""
}

variable "eks_cluster_endpoint" {
  description = "The hostname (in form of URI) of Kubernetes master/data.terraform_remote_state.eks.outputs.cluster_endpoint"
  type = string
  default = ""
}

variable "eks_cluster_certificate_authority_data" {
  description = "PEM-encoded root certificates bundle for TLS authentication./data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data"
  type = string
  default = ""
}

variable "json_policy" {
  description = "Input Policy that is used for IRSA"
  type = string
  default = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ], 
      "Resource": "*"
    }
  ]
}
EOT
}

variable "k8s_namespace" {
  description = "In Kubernetes (k8s), a namespace is a virtual cluster or an environment created within the actual Kubernetes cluster. It provides a scope for names and allows you to divide cluster resources between multiple users, teams, projects, or customers."
  type = string
  default = ""
}


variable "k8s_service_account" {
  description = "Service accounts in Kubernetes are accounts that are meant to be used by services (like pods) running in a Kubernetes cluster, rather than by human users. They provide an identity for processes that run in a Pod."
  type = string
  default = ""
}