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
