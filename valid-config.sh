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
