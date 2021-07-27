## Gitlab Chart

### Prepare

- Install tools:  
  - [helm](https://helm.sh/docs/intro/install/): v3.6.2  
  - [helmfile](https://github.com/roboll/helmfile): v0.139.9

- Install helm plugin   
  - [helm-secrets](https://github.com/zendesk/helm-secrets)

### Encrypt / Decrypt secret with AWS KMS (Gitlab Init Chart)

- AWS KMS: `arn:aws:kms:eu-west-1:443998502738:key/4781c8e0-d6b7-4c51-b417-9966c37bef7c`

- How to use:  

  - To encrypt the secret: `helm secrets enc secrets.yaml`    
  - To view the secret: `helm secrets view secrets.yaml`  
  - To edit the secret: `helm secrets edit secrets.yaml`  
  - To decrypt the secret: `helm secrets dec secrets.yaml`   

- Reference document:
  - https://github.com/zendesk/helm-secrets


### Deploy Gitlab Init chart

- Purpose:
  - Create a storageclass
  - Create a secrets

- [Usage](https://github.com/roboll/helmfile):
  - Check diff: `helmfile --file=helmfile.yaml diff`
  - Deploy/Upgrade:  `helmfile --file=helmfile.yaml apply`
  - Destroy:  `helmfile --file=helmfile.yaml destroy`

- Deploy / upgrade chart

  ```sh
  cd charts/init
  helmfile --file=helmfile.yaml apply
  ```

- charts/init/secrets.yaml

  ```yml
  secrets:
      gitlab_db_passwd: <rds_database_password>
      gitlab_init_root_passwd: <gitlab_root_password>
      gitlab_s3_credential: |
          provider: AWS
          region: eu-west-1
          use_iam_profile: true
      gitlab_s3cmd_credential: |
          [default]
              access_key = <aws_access_key>
              secret_key =  <aws_secret_key>
              bucket_location = eu-west-1
              multipart_chunk_size_mb = 128
      gitlab_s3_registry_credential: |
          s3:
            bucket: 443998502738-eu-west-1-poc-gitlab-registry
            accesskey: <aws_access_key>
            secretkey: <aws_secret_key>
            region: eu-west-1
            v4auth: true  
  ```
  **Note**: 
  - At the momment, gitlab task runner & gitlab registry chart are [not supporting OIDC authentication](https://github.com/s3tools/s3cmd/issues/1075). Workaround here is we need create an IAM user has permission allow to access to S3 resources & provide both `aws access key` & `aws secret key` at the configuration above. Furthermore this issue, checkout the links below:
  
    - https://gitlab.com/gitlab-org/charts/gitlab/-/blob/v5.1.0/doc/advanced/external-object-storage/aws-iam-roles.md#using-iam-roles-for-service-accounts
    - https://github.com/s3tools/s3cmd/pull/1112

  - To get the `rds_database_password`, going back to `terraform/environments/poc` directory, run the command:

    ```sh
    sops -d secrets.yaml 
    postgres_db_password: ***
    ```
  - To get the `aws_access_key` & `aws_secret_key`, going back to `terraform/environments/poc` directory, run the command:

    ```sh
    terragrunt outputs
    ...
    iam_access_key = "***"
    iam_secret_key = "***"
    ```

  - `gitlab_init_root_passwd` is pre-defined password, we need set a value in here.

  - To put the object to s3, Gitlab Registry is based on [S3 storage driver](https://docs.docker.com/registry/storage-drivers/s3/), and task-runner is [s3cmd](https://s3tools.org/kb/item14.htm). Checkout these document to deep more detail.


### Deploy Gitlab chart

- Note: This chart is develop base on [gitlab/gitlab](https://gitlab.com/gitlab-org/charts/gitlab/-/tree/v5.1.1) chart.
  - Chart version: v5.1.1
  - Gitlab version: 14.1.1-ee

- Deploy / upgrade chart

  ```sh
  cd charts/gitlab
  helmfile --file=helmfile.yaml apply
  ```

- Check all the resources are deployed

  ```sh
  kubectl get all -n gitlabeks
  NAME                                              READY   STATUS      RESTARTS   AGE
  pod/gitlab-gitaly-0                               1/1     Running     0          7h1m
  pod/gitlab-gitlab-shell-65bd4b95b5-4b55q          1/1     Running     0          6h26m
  pod/gitlab-migrations-8-4dtb4                     0/1     Completed   0          5h10m
  pod/gitlab-registry-b76b7f944-dsxwt               1/1     Running     0          7h15m
  pod/gitlab-sidekiq-all-in-1-v1-6785d9dbc9-9khp2   1/1     Running     0          6h27m
  pod/gitlab-sidekiq-all-in-1-v1-6785d9dbc9-gh9nj   1/1     Running     0          6h27m
  pod/gitlab-task-runner-5675ff76fb-g6qtj           1/1     Running     0          6h40m
  pod/gitlab-webservice-default-d5b46dbcb-5vj2f     2/2     Running     0          6h30m
  pod/gitlab-webservice-default-d5b46dbcb-dv94f     2/2     Running     0          6h30m

  NAME                                TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)             AGE
  service/gitlab-gitaly               ClusterIP      None            <none>                                                                   8075/TCP            7h19m
  service/gitlab-gitlab-shell         LoadBalancer   172.20.xx.xx   xxxx.eu-west-1.elb.amazonaws.com   22:30183/TCP        7h19m
  service/gitlab-registry             ClusterIP      172.20.xx.xx   <none>                                                                   5000/TCP            7h15m
  service/gitlab-webservice-default   ClusterIP      172.20.xx.xx   <none>                                                                   8080/TCP,8181/TCP   7h19m

  NAME                                         READY   UP-TO-DATE   AVAILABLE   AGE
  deployment.apps/gitlab-gitlab-shell          1/1     1            1           7h19m
  deployment.apps/gitlab-registry              1/1     1            1           7h15m
  deployment.apps/gitlab-sidekiq-all-in-1-v1   2/2     2            2           7h19m
  deployment.apps/gitlab-task-runner           1/1     1            1           7h19m
  deployment.apps/gitlab-webservice-default    2/2     2            2           7h19m

  NAME                                                    DESIRED   CURRENT   READY   AGE
  replicaset.apps/gitlab-gitlab-shell-65bd4b95b5          1         1         1       6h26m
  replicaset.apps/gitlab-gitlab-shell-67dcb66cd4          0         0         0       7h2m
  replicaset.apps/gitlab-gitlab-shell-f7ff7795b           0         0         0       7h19m
  replicaset.apps/gitlab-registry-b76b7f944               1         1         1       7h15m
  replicaset.apps/gitlab-sidekiq-all-in-1-v1-6785d9dbc9   2         2         2       6h27m
  replicaset.apps/gitlab-sidekiq-all-in-1-v1-695cc988cd   0         0         0       7h19m
  replicaset.apps/gitlab-sidekiq-all-in-1-v1-6cd4d9d68c   0         0         0       6h56m
  replicaset.apps/gitlab-sidekiq-all-in-1-v1-76ddc5f474   0         0         0       6h41m
  replicaset.apps/gitlab-sidekiq-all-in-1-v1-d9fdd79d     0         0         0       7h2m
  replicaset.apps/gitlab-task-runner-5675ff76fb           1         1         1       6h40m
  replicaset.apps/gitlab-task-runner-6d9b69cb6c           0         0         0       7h1m
  replicaset.apps/gitlab-task-runner-9cdf7c55f            0         0         0       6h55m
  replicaset.apps/gitlab-task-runner-b8df77948            0         0         0       7h19m
  replicaset.apps/gitlab-webservice-default-58bb8b6c79    0         0         0       7h19m
  replicaset.apps/gitlab-webservice-default-66d7fc9d77    0         0         0       6h56m
  replicaset.apps/gitlab-webservice-default-6b8785df69    0         0         0       6h41m
  replicaset.apps/gitlab-webservice-default-7fb56f74d     0         0         0       7h2m
  replicaset.apps/gitlab-webservice-default-d5b46dbcb     2         2         2       6h30m

  NAME                             READY   AGE
  statefulset.apps/gitlab-gitaly   1/1     7h19m

  NAME                                                             REFERENCE                               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
  horizontalpodautoscaler.autoscaling/gitlab-gitlab-shell          Deployment/gitlab-gitlab-shell          4m/300m    1         1         1          7h19m
  horizontalpodautoscaler.autoscaling/gitlab-registry              Deployment/gitlab-registry              2%/75%     1         1         1          7h15m
  horizontalpodautoscaler.autoscaling/gitlab-sidekiq-all-in-1-v1   Deployment/gitlab-sidekiq-all-in-1-v1   35m/700m   2         2         2          7h19m
  horizontalpodautoscaler.autoscaling/gitlab-webservice-default    Deployment/gitlab-webservice-default    7m/700m    2         2         2          7h19m

  NAME                            COMPLETIONS   DURATION   AGE
  job.batch/gitlab-migrations-8   1/1           43s        5h10m

  NAME                                      SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
  cronjob.batch/gitlab-task-runner-backup   0 1 * * *   False     0        <none>          7h19m


  ```


## Setup Route 53

- Get svc, ingress

  ```sh
  kubectl get svc,ingress -n gitlabeks
  NAME                                TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)             AGE
  service/gitlab-gitaly               ClusterIP      None            <none>                                                                   8075/TCP            7h21m
  service/gitlab-gitlab-shell         LoadBalancer   172.20.xx.xx   xxxx.eu-west-1.elb.amazonaws.com   22:30183/TCP        7h21m
  service/gitlab-registry             ClusterIP      172.20.xx.xx   <none>                                                                   5000/TCP            7h17m
  service/gitlab-webservice-default   ClusterIP      172.20.xx.xx   <none>                                                                   8080/TCP,8181/TCP   7h21m

  NAME                                           CLASS    HOSTS                                   ADDRESS                                                                   PORTS     AGE
  ingress.extensions/gitlab-registry             <none>   registry-gitlabeks.example.com   xxxx.eu-west-1.elb.amazonaws.com   80, 443   7h17m
  ingress.extensions/gitlab-webservice-default   <none>   gitlabeks.example.com            xxxx.eu-west-1.elb.amazonaws.com    80, 443   7h21m
  ``

- Add the records (hostzone: example.com)

  | Record Name | Type | Route Traffic To |
  | :---        | :--- | :--- |
  | gitlabeks.example.com | CNAME | xxxx.eu-west-1.elb.amazonaws.com |
  | registry-gitlabeks.example.com | CNAME | xxxx.eu-west-1.elb.amazonaws.com |
  | ssh-gitlabeks.example.com | CNAME | xxxx.eu-west-1.elb.amazonaws.com |

