#!/bin/sh

# To load the needed functions
source ~/bash-config/common.sh

echo " "
echo " "
echo " "
echo "################################################"
echo " "
echo "Have a cluster with Operator and Vault installed"
echo " "
echo "################################################"
createcluster nodeport
installoperator nodeport
kubectl apply -f https://raw.githubusercontent.com/cniackz/kes-testing/main/deployment.yaml
kubectl wait --namespace default \
	--for=condition=ready pod \
	--selector=app=vault \
	--timeout=120s

















































echo " "
echo " "
echo " "
echo "################"
echo " "
echo "Configure Vault:"
echo " "
echo "################"
sleep 2
# hvs.llM5QYQF9Cg10SowEudvf2j5 <--- VAULT_ROOT_TOKEN example
VAULT_ROOT_TOKEN=$(kubectl logs -l app=vault | grep "Root Token: " | sed -e "s/Root Token: //g")
echo "VAULT_ROOT_TOKEN: ${VAULT_ROOT_TOKEN}"

# Expected: Success! Enabled approle auth method at: approle/
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault auth enable approle'

# Expected: Success! Enabled the kv secrets engine at: kv/
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault secrets enable kv'

kubectl cp ~/operator/examples/vault/kes-policy.hcl $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}'):/kes-policy.hcl

# Expected: Success! Uploaded policy: kes-policy
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault policy write kes-policy /kes-policy.hcl'

# Success! Data written to: auth/approle/role/kes-role
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault write auth/approle/role/kes-role token_num_uses=0 secret_id_num_uses=0 period=5m policies=kes-policy'

# Expected: 003ea2c3-983d-e283-1f93-0c6baa2a710e
ROLE_ID=$(kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault read auth/approle/role/kes-role/role-id' | grep "role_id    " | sed -e "s/role_id    //g")
echo "ROLE_ID: ${ROLE_ID}"

# Expected: 0f4289bd-6fb0-4271-483f-0c7d0d1cce44
SECRET_ID=$(kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault write -f auth/approle/role/kes-role/secret-id' | grep "secret_id             " | sed -e "s/secret_id             //g")
echo "SECRET_ID: ${SECRET_ID}"

















































echo " "
echo " "
echo " "
echo "#######################"
echo " "
echo "Apply KES Configuration"
echo " "
echo "#######################"
sleep 2
echo "apiVersion: v1
kind: Secret
metadata:
  name: kes-tenant-secret-kes-configuration
  namespace: default
  uid: 62bd80c5-d94d-4b6b-9fa2-06b346d2f39d
  resourceVersion: '1084'
  creationTimestamp: '2022-11-29T14:29:22Z'
  labels:
    v1.min.io/tenant: kes-tenant
  managedFields:
    - manager: console
      operation: Update
      apiVersion: v1
      time: '2022-11-29T14:29:22Z'
      fieldsType: FieldsV1
      fieldsV1:
        f:data:
          .: {}
          f:server-config.yaml: {}
        f:immutable: {}
        f:metadata:
          f:labels:
            .: {}
            f:v1.min.io/tenant: {}
        f:type: {}
  selfLink: /api/v1/namespaces/default/secrets/kes-tenant-secret-kes-configuration
immutable: true
type: Opaque
stringData:
  server-config.yaml: |-
    version: v1
    address: 0.0.0.0:7373
    admin:
      identity: \${MINIO_KES_IDENTITY}
    tls:
      key: /tmp/kes/server.key
      cert: /tmp/kes/server.crt
    api:
      /v1/ready:
        skip_auth: false
        timeout:   15s
    cache:
      expiry:
        any: 5m0s
        unused: 20s
        offline: 0s
    log:
      error: on
      audit: off
    keys:
      - name: myminio-key
    keystore:
      vault:
        endpoint: http://vault.default.svc.cluster.local:8200
        prefix: my-minio
        approle:
          id: ${ROLE_ID}
          secret: ${SECRET_ID}
        status: {}" > kes-configuration.yaml
kubectl apply -f kes-configuration.yaml






















































echo " "
echo " "
echo " "
echo "######################################"
echo " "
echo "Create Environment Variables for MinIO"
echo " "
echo "######################################"
sleep 2
echo "apiVersion: v1
kind: Secret
metadata:
  name: kes-tenant-env-configuration
  namespace: default
  uid: c89ddc64-a723-41cf-8a8d-8ecd0d8c88d8
  resourceVersion: '1085'
  creationTimestamp: '2022-11-29T14:29:22Z'
  labels:
    v1.min.io/tenant: kes-tenant
  managedFields:
    - manager: console
      operation: Update
      apiVersion: v1
      time: '2022-11-29T14:29:22Z'
      fieldsType: FieldsV1
      fieldsV1:
        f:data:
          .: {}
          f:config.env: {}
        f:metadata:
          f:labels:
            .: {}
            f:v1.min.io/tenant: {}
        f:type: {}
  selfLink: /api/v1/namespaces/default/secrets/kes-tenant-env-configuration
type: Opaque
stringData:
  config.env: |-
    export MINIO_BROWSER=\"on\"
    export MINIO_ROOT_USER=\"WHNXZOGKN5IQIPQD\"
    export MINIO_ROOT_PASSWORD=\"4IJJVSFGVCJV4X2HGRK1K04KCLRIWT1Q\"
    export MINIO_STORAGE_CLASS_STANDARD=\"EC:2\"" > kes-env.yaml
kubectl apply -f kes-env.yaml



















































echo " "
echo " "
echo " "
echo "###################"
echo " "
echo "Create Console User"
echo " "
echo "###################"
sleep 2
echo "apiVersion: v1
kind: Secret
metadata:
  name: kes-tenant-user-0
  namespace: default
  uid: 08f62e3e-3ac1-4199-af46-9ee7a0cc4e15
  resourceVersion: '1083'
  creationTimestamp: '2022-11-29T14:29:22Z'
  labels:
    v1.min.io/tenant: kes-tenant
  managedFields:
    - manager: console
      operation: Update
      apiVersion: v1
      time: '2022-11-29T14:29:22Z'
      fieldsType: FieldsV1
      fieldsV1:
        f:data:
          .: {}
          f:CONSOLE_ACCESS_KEY: {}
          f:CONSOLE_SECRET_KEY: {}
        f:immutable: {}
        f:metadata:
          f:labels:
            .: {}
            f:v1.min.io/tenant: {}
        f:type: {}
  selfLink: /api/v1/namespaces/default/secrets/kes-tenant-user-0
immutable: true
type: Opaque
data:
  CONSOLE_ACCESS_KEY: Y29uc29sZQ==
  CONSOLE_SECRET_KEY: Y29uc29sZTEyMw==" > kes-console.yaml
kubectl apply -f kes-console.yaml




























































echo " "
echo " "
echo " "
echo "############"
echo " "
echo "Apply Tenant"
echo " "
echo "############"
sleep 2
echo "apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  generation: 2
  name: kes-tenant
  namespace: default
spec:
  certConfig:
    commonName: '*.kes-tenant-hl.default.svc.cluster.local'
    dnsNames:
    - kes-tenant-pool-0-{0...3}.kes-tenant-hl.default.svc.cluster.local
    organizationName:
    - system:nodes
  configuration:
    name: kes-tenant-env-configuration
  credsSecret:
    name: kes-tenant-secret
  exposeServices:
    console: true
    minio: true
  image: minio/minio:RELEASE.2023-10-16T04-13-43Z
  imagePullPolicy: IfNotPresent
  imagePullSecret: {}
  kes:
    image: "minio/kes:2023-10-03T00-48-37Z" # put latest for testing
    imagePullPolicy: IfNotPresent
    kesSecret:
      name: kes-tenant-secret-kes-configuration
    keyName: my-minio-key
    replicas: 1
    resources: {}
    securityContext:
      fsGroup: 1000
      fsGroupChangePolicy: Always
      runAsGroup: 1000
      runAsNonRoot: true
      runAsUser: 1000
  mountPath: /export
  podManagementPolicy: Parallel
  pools:
  - affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: v1.min.io/tenant
              operator: In
              values:
              - kes-tenant
            - key: v1.min.io/pool
              operator: In
              values:
              - pool-0
          topologyKey: kubernetes.io/hostname
    name: pool-0
    resources: {}
    servers: 4
    volumeClaimTemplate:
      metadata:
        name: data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: \"26843545600\"
        storageClassName: standard
      status: {}
    volumesPerServer: 1
  requestAutoCert: true
  users:
  - name: kes-tenant-user-0" > kes-tenant.yaml
kubectl apply -f kes-tenant.yaml





















