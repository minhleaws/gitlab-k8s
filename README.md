# GitLab HelmChart POC

## Setup AWS Profile

Step 1: [Setup AWS User](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

- Create an IAM User: gitlab-iac
- Attached directory permission: AdministratorAccess
- Create access key

Step2: [Setup AWS Profile on your local machine, following the context below](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

- ~/.aws/config

  ```
  [profile gitlab-helmchart-poc]
  region = eu-west-1  
  ```

- ~/.aws/credentials

  ```
  [gitlab-helmchart-poc]
  aws_access_key_id = ***
  aws_secret_access_key = ***
  ```

## Provision AWS Infrastructure as Code

Checkout the document [here](terraform/readme.md)

## Deploy Gitlab on EKS cluster via Helm chart

Checkout the document [here](charts/readme.md)
