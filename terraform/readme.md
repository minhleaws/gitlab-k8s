## Terraform - IaC

### Prepare

- Create terraform s3 backend bucket: `gitlab-poc-terraform-backend-state`

- Install tools:
  - [terraform](https://www.terraform.io/downloads.html): v1.0.1  
  - [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/): v0.31.0  
  - [sops](https://github.com/mozilla/sops): v3.7.1  
  - [kubectl](https://kubernetes.io/docs/tasks/tools/): v1.18.0
  - [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html): v0.58.0

### Setup Sops & AWS KMS to Encrypt secrets value (secrets.yaml)

- Create AWS KMS: `arn:aws:kms:eu-west-1:xxxx:key/4781c8e0-d6b7-4c51-b417-9966c37bef7c`

- Usage:  
  - To encrypt data: `sops --encrypt secrets.dec.yaml > secrets.yaml`  
  - To view data:  `sops --decrypt secrets.yaml`  

  *secrets.dec.yaml file will be remove after encrypted*

- Reference document
  - https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1
  - https://www.varokas.com/secrets-in-code-with-mozilla-sops/
  

### Basic usage

`Terragrunt` is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state. Checkout the document [here](https://terragrunt.gruntwork.io/) to get more about it.

Basic usage:

- To review plan: `terragrunt plan`
- To provision resource: `terragrunt apply`
- To destroy resource: `terragrunt destroy`



### The order resources will be provision

- ssh-keypairs (create ssh keypairs)

  ```sh
  cd terraform/environments/poc/ssh-keypairs
  terragrunt apply
  ```

- bastion (create bastion vm, security group & rules, instance profile), this is optional to debuging such as connection, ssh into worker node ...

  ```sh
  cd terraform/environments/poc/bastion
  terragrunt apply
  ```

- gitlab-s3 (LFS, Artifacts, Uploads, Packages, External MR diffs, and Dependency Proxy ...)

    ```sh
    cd terraform/environments/poc/gitlab-s3
    terragrunt apply
    ```

- database  

  - elasticache-redis (replication group, parameter group, subnet group, security group & rules)

    ```sh
    cd terraform/environments/poc/database/elasticache-redis
    terragrunt apply
    ```

  - rds-postgresql (db instance, parameter group, subnet group, security group & rules)  

    ```sh
    cd terraform/environments/poc/database/rds-postgresql
    terragrunt apply
    ```  

- gitlab-eks

  - eks-cluster (create cluster, security group & rules, iam role & policy for cluser, openid)

    ```sh
    cd terraform/environments/poc/database/gitlab-eks
    terragrunt apply
    ```  


  - eks-nodegroup-01 (create nodegroup, iam role & policy)   

    ```sh
    cd terraform/environments/poc/database/eks-nodegroup-01
    terragrunt apply
    ```

- gitlab-serviceaccount (create iam role for service account, namespace, service account inside namespace of kubernetes cluster)

  ```sh
  cd terraform/environments/poc/gitlab-serviceaccount
  terragrunt apply
  ```

  The default namespace is `gitlabeks`


- gitlab-wafv2

  ```sh
  cd terraform/environments/poc/gitlab-wafv2
  terragrunt apply
  ```


### Connect to EKS cluster & basic setup common resources

- Access to EKS cluster

  ```sh
  aws eks --region eu-west-1 update-kubeconfig --name gitlabeks-eks-cluster --profile gitlab-helmchart-poc
  ```

- Get all nodes in cluster

  ```sh
  kubectl get nodes
  NAME                                       STATUS   ROLES    AGE   VERSION
  ip-10-3-0-218.eu-west-1.compute.internal   Ready    <none>   34h   v1.18.9-eks-d1db3c
  ip-10-3-2-124.eu-west-1.compute.internal   Ready    <none>   34h   v1.18.9-eks-d1db3c
  ```

- [Install metric API server](https://github.com/kubernetes-sigs/metrics-server)

  ```sh
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
  ```

  ```sh
  kubectl top nodes
  NAME                                      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
  ip-10-3-0-14.eu-west-1.compute.internal   59m          3%     463Mi           13%       
  ip-10-3-2-58.eu-west-1.compute.internal   48m          2%     451Mi           13%   
  ```

- [Install AWS Loadbalancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)  

  ```sh
  curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json
  ```

  ```sh
  aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json \
    --profile gitlab-helmchart-poc
  ```

  ```sh
  {
      "Policy": {
          "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
          "PolicyId": "ANPAWOYC7P5JJNSVDWEAE",
          "Arn": "arn:aws:iam::xxxx:policy/AWSLoadBalancerControllerIAMPolicy",
          "Path": "/",
          "DefaultVersionId": "v1",
          "AttachmentCount": 0,
          "PermissionsBoundaryUsageCount": 0,
          "IsAttachable": true,
          "CreateDate": "2021-07-28T14:20:21Z",
          "UpdateDate": "2021-07-28T14:20:21Z"
      }
  }  
  ```

  ```sh
  eksctl create iamserviceaccount \
    --cluster=gitlabeks-eks-cluster \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::xxxx:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve \
    --profile  gitlab-helmchart-poc
  ```

  ```sh
  2021-07-28 23:14:18 [ℹ]  eksctl version 0.58.0
  2021-07-28 23:14:18 [ℹ]  using region eu-west-1
  2021-07-28 23:14:22 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
  2021-07-28 23:14:22 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
  2021-07-28 23:14:22 [ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "kube-system/aws-load-balancer-controller", create serviceaccount "kube-system/aws-load-balancer-controller" } }
  2021-07-28 23:14:22 [ℹ]  building iamserviceaccount stack "eksctl-gitlabeks-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
  2021-07-28 23:14:22 [ℹ]  deploying stack "eksctl-gitlabeks-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
  2021-07-28 23:14:22 [ℹ]  waiting for CloudFormation stack "eksctl-gitlabeks-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
  2021-07-28 23:14:39 [ℹ]  waiting for CloudFormation stack "eksctl-gitlabeks-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
  2021-07-28 23:14:56 [ℹ]  waiting for CloudFormation stack "eksctl-gitlabeks-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
  2021-07-28 23:14:59 [ℹ]  created serviceaccount "kube-system/aws-load-balancer-controller"
  ```

  ```sh
  Name:                aws-load-balancer-controller
  Namespace:           kube-system
  Labels:              app.kubernetes.io/managed-by=eksctl
  Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::xxxx:role/eksctl-gitlabeks-eks-cluster-addon-iamservic-Role1-1340ACTY1HMEH
  Image pull secrets:  <none>
  Mountable secrets:   aws-load-balancer-controller-token-gjfws
  Tokens:              aws-load-balancer-controller-token-gjfws
  Events:              <none>
  ```

  ```sh
  kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
  customresourcedefinition.apiextensions.k8s.io/ingressclassparams.elbv2.k8s.aws created
  customresourcedefinition.apiextensions.k8s.io/targetgroupbindings.elbv2.k8s.aws created
  ```

  ```sh
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update

  helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=gitlabeks-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system
  ```

  ```sh
  Release "aws-load-balancer-controller" does not exist. Installing it now.
  NAME: aws-load-balancer-controller
  LAST DEPLOYED: Wed Jul 28 23:20:03 2021
  NAMESPACE: kube-system
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  NOTES:
  AWS Load Balancer controller installed!
  ```

  ```sh
  kubectl get deployment -n kube-system aws-load-balancer-controller
  NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
  aws-load-balancer-controller   2/2     2            2           47s 
  ```

  **Important**: Must be tagged as follows so that Kubernetes and the AWS load balancer controller know that the subnets can be used for internal load balancers. Please checkout the document [here](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
  
  - private subnet:  

      ```
      key: kubernetes.io/role/internal-elb  
      kalue: 1
      ```

  - public subnet

      ```
      key: kubernetes.io/role/elb  
      kalue: 1
      ```

  Now, we are ready to deploy Gitlab chart !!!
