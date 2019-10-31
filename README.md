# awscli-kubectl

This Docker Image includes the AWS CLI and Kubectl.
It also includes an ***ECR Token-Kube Secret*** Update Script which is located in ***/root/update-secret.sh***

---

## Example Usage:
### AWS Credentials
... are stored in a Kubernetes Secret
```
kind: Secret
apiVersion: v1
metadata:
  name: aws-cli-user
  labels:
    app: aws-ecr-credentials-updater
stringData:
  aws_access_key_id: ___YOUR_AWS_ACCESS_KEY_ID___
  aws_secret_access_key: ___YOUR_AWS_SECRET___
```

### The Cronjob
... runs every 8 hours and refreshes the ECR Token.

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: aws-ecr-credentials-updater
spec:
  schedule: "* */8 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: awscli-kubectl
            image: eltomato/awscli-kubectl:latest
            imagePullPolicy: Always
            env:
            - name: AWS_DEFAULT_REGION
              value: eu-central-1
            - name: AWS_ACCOUNT
              value: ___YOUR_AWS_ACCOUNT_ID___
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: aws-cli-user
                  key: aws_access_key_id
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: aws-cli-user
                  key: aws_secret_access_key
            - name: KUBE_SECRET_NAME
              value: __SECRET_NAME_WHERE_CRON_SHOULD_STORE_THE_ECR_SECRET___
            args:
            - /bin/sh
            - -c
            - "aws eks update-kubeconfig --name ___YOUR_EKS_CLUSTER_NAME___ && /root/update-secret.sh"
          restartPolicy: Never

```

This Example runs every 8 hours, gets the ECR docker-login Token and stores it into a Kubernetes Secret ..

But you can use the AWS CLI as you like ..
