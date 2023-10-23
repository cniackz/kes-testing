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
  image: minio/minio:RELEASE.2022-11-26T22-43-32Z
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
k apply -f kes-tenant.yaml
