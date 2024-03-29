#!/bin/bash
set -e

regex="docker login -u (.+) -p (.+) -e (.+) (.+)"
if [[ $(aws ecr get-login --region ${AWS_DEFAULT_REGION}) =~ $regex ]]
then
  login=$(echo "${BASH_REMATCH[1]}:${BASH_REMATCH[2]}" | base64)
  echo "Configuring registry ${BASH_REMATCH[4]:8}..."
  dockerconfig="{\"auths\":{\"${BASH_REMATCH[4]:8}\":{\"auth\": \"${login}\"}}}"
  dockerconfigjson=$(echo ${dockerconfig} | base64 -w0)
  secret="apiVersion: v1\nkind: Secret\nmetadata:\n  name: ${KUBE_SECRET_NAME}\ndata:\n  .dockerconfigjson: ${dockerconfigjson}\ntype: kubernetes.io/dockerconfigjson"
  echo -e ${secret} | kubectl replace -f - --force
  cat <<EOF

In order to use the new secret to pull images, add the following to your Pod definition:

    spec:
      imagePullSecrets:
        - name: ${KUBE_SECRET_NAME}
      [...]

Remember that AWS ECR login credentials expire in 12 hours!

More info at https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
EOF
fi
