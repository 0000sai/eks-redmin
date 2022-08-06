# Redmine AWS EKS Setup

## Deployments 

1. Terraform Vpc
2. Terraform Eks(eksctl)
3. Terraform Rds
4. Terraform Kms
5. Terraform Eks-Drivers-(EBS-CSI + SecretStore-CSI)
6. Terraform ALB-Ingress-Setup
## AWS SecretManager
7. Eks-Application/SecretsDecryption-OIDC

## Bitnami Sealed Secrets
8. Bitnami Sealed Secrets 

- Prerequisites

1. ACM Setup with your domain (Optional)

2. packages Installed in provided packages.sh

3. Docker (Optional)

4. VsCode (Optional)

- Steps

1. cd eks/environment/dev

2. aws configure 

3. terraform apply

4. Resources Provisioned VPC, RDS, KMS, AWS Secrets,EKS CLUSTER, EKS Manged Nodes

## MYSQL Client
- Connect to MYSQL Database 
- Make Sure to Allow WorkerNodeSG in RDS SG
```mysql
kubectl run -it --rm --image=mysql:5.7 --restart=Never mysql-client -- mysql -h redmine-db.cpyuhbq10eou.us-east-1.rds.amazonaws.com -u dbadmin -p12345678
```
- Verify Database
mysql> show schemas;

- curl pod for trouble shooting

```curlpod
kubectl run -n cloudgeeks -it --rm --image=curlimages/curl --restart=Never curl-pod -- sh
```

## Creds Create these in Secret Manager & Attach a ReadOnly policy with WorkerNodeGroup Role


- Best is to Use Bitnami Sealed Secrets, currently aws does not provide KEY Value

1. REDMINE_DB_USERNAME=dbadmin         ---> Create these in Secret Manager

2. REDMINE_DB_PASSWORD=12345678        ---> Create these in Secret Manager

3. REDMINE_SECRET_KEY_BASE=12345678    ---> Create these in Secret Manager

4. REDMINE_DB_MYSQL                    ---> Create these in Secret Manager       ---> Rds Endpoint

rds-secrets with regex

```secrets
export REDMINE_DB_USERNAME=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq '."REDMINE_DB_USERNAME"' | cut -f2 -d '"')

export REDMINE_DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq '."REDMINE_DB_PASSWORD"' | cut -f2 -d '"')

export REDMINE_SECRET_KEY_BASE=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq '."REDMINE_SECRET_KEY_BASE"' | cut -f2 -d '"')

export REDMINE_DB_MYSQL=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq '."REDMINE_DB_MYSQL"' | cut -f2 -d '"')
```

- rds-secrets with jq

```secrets
export REDMINE_DB_USERNAME=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq -r '."REDMINE_DB_USERNAME"')

export REDMINE_DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq -r '."REDMINE_DB_PASSWORD"')

export REDMINE_SECRET_KEY_BASE=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq -r '."REDMINE_SECRET_KEY_BASE"')

export REDMINE_DB_MYSQL=$(aws secretsmanager get-secret-value --secret-id redmine-creds --region us-east-1 --query SecretString --output text | jq -r '."REDMINE_DB_MYSQL"')

```

## Secrets Mounting

```secrets
export REDMINE_DB_USERNAME=$(cat /mnt/password/redmine-creds | awk -F [:,] '{print $2}' | cut -f2 -d '"')

export REDMINE_DB_PASSWORD=$(cat /mnt/password/redmine-creds | awk -F [:,] '{print $4}' | cut -f2 -d '"')

export REDMINE_SECRET_KEY_BASE=$(cat /mnt/password/redmine-creds | awk -F [:,] '{print $6}' | cut -f2 -d '"')

export REDMINE_DB_MYSQL=$(cat /mnt/password/redmine-creds | awk -F [:,] '{print $8}' | cut -f2 -d '"')
```

## Example Secrets/Configmaps
```example
Sample ConfigMap declaration form.

cat <<EOF > configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
     name: credentials
     namespace: learning
data:
     username: root
     password: password
EOF
     
Creating ConfigMap using an imperative method.

Method 1.

kubectl -n learning create configmap asim-credentials  \
               --from-literal=username=root \
               --from-literal=password=password \
               --from-literal=shell=bash
               
Method 2.

Create a feeder file.

vi ref.txt

username: root
password: password

Create ConfigMap.

kubectl -n learning create configmap family-credentials \
               --from-file=ref.txt
               
Sample Pod Definition File.

1.Fetching environment variables from a ConfigMap object.

cat <<EOF > configmap-test.yaml
apiVersion: v1
kind: Pod
metadata: 
   name: configmap-test-1
   namespace: learning
spec:
   containers:
     - name: nginx
       image: nginx:alpine
       env: ############################################# difference
         - name: CONFIG_SHELL_TEST
           valueFrom:
             configMapKeyRef:
                   name: credentials
                   key: password
EOF

kubectl apply -f configmap-test.yaml          
 
 

2.Injecting a ConfigMap 'key-values' to the environment of a Pod.

cat <<EOF > configmap-test2.yaml
apiVersion: v1
kind: Pod
metadata: 
   name: configmap-test-2
   namespace: learning
spec:
   containers:
     - name: nginx
       image: nginx:alpine     
       envFrom: ############################################# difference
        - configMapRef:
             name: credentials                  
EOF

kubectl apply -f configmap-test2.yaml               
                   
                   
                   
#################################                   
3.Mapping the ConfigMap in a Pod.
#################################
cat <<EOF > configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
     name: credentials
     namespace: learning
data:
     username: root
     password: password
EOF

cat <<EOF > configmap-test3.yaml
apiVersion: v1
kind: Pod
metadata: 
   name: configmap-test-3
   namespace: learning
spec:
   containers:
     - name: nginx
       image: nginx:alpine     
       volumeMounts: ############################################# difference
           - name: cm-mount     # must match
             mountPath: /configmap
             readOnly: true
   volumes:
      - name: cm-mount            # must match
        configMap:
            name: credentials
EOF

kubectl apply -f configmap-test3.yaml 

```
- port-forward
- https://github.com/kubernetes/kubernetes/issues/40053

```portforward
kubectl port-forward svc/[service-name] -n [namespace] [external-port]:[internal-port] --address='0.0.0.0'

kubectl port-forward service/jaeger -n linkerd-jaeger  --address='0.0.0.0' 9090:16686
```
- Github issue https://github.com/linkerd/linkerd2/issues/8343

5. Terraform Destroy
