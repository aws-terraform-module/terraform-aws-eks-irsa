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
  source  = "aws-terraform-module/eks-irsa/aws"
  version = "1.1.0"

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

Next then, Notice irsa_iam_role_arn output and add this value to annotion of you application

```yaml
root@LP11-D7891:~# kubectl get sa/irsa-demo-sa -o yaml
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  annotations:
    ###### Notice below line #####
    eks.amazonaws.com/role-arn: arn:aws:iam::250887682577:role/SAP-dev-irsa-iam-role
  creationTimestamp: "2022-09-08T05:39:20Z"
  name: irsa-demo-sa
  namespace: default
  resourceVersion: "208932"
  uid: 4c6298b9-d888-4212-8a71-67a242b24b1f
secrets:
- name: irsa-demo-sa-token-vdstw
```