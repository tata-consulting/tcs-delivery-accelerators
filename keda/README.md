# KEDA ScaledObject Templates

KEDA (Kubernetes Event-Driven Autoscaling) configurations for scaling services based on external event sources.

## Scaler Selection Guide

| Trigger | Scaler | Min Replicas | Notes |
|---------|--------|-------------|-------|
| SQS queue depth | `sqs` | 1 (prod), 1 (dev) | Can't scale to zero - SQS doesn't push |
| Kafka consumer lag | `kafka` | 0 (dev), 1 (prod) | Scale-to-zero supported |
| HTTP request rate | `http` | 0 (dev), 1 (prod) | Requires HTTP add-on; has cold start latency |

## SQS Scaler

Use for services that consume from an AWS SQS queue. Scales based on queue depth.

**Key parameters:**
- `queueLength`: Messages per replica before scaling up. Default: 5. Tune based on processing throughput.
- `queueLengthStrategy: visibleAndNotVisible`: Includes in-flight messages. Required to prevent scale-down while messages are being processed.
- `cooldownPeriod: 300`: Wait 5 minutes before scaling down. Prevents thrashing.

**Authentication:** IRSA (no static credentials). The pod's service account must be annotated with the IAM role ARN:
```yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account>:role/<service>-keda-role
```

Required IAM permissions: `sqs:GetQueueAttributes`, `sqs:GetQueueUrl`.

## Kafka Scaler

Use for services that consume from a Kafka topic using a consumer group. Scales based on consumer lag.

**Key parameters:**
- `lagThreshold`: Target unprocessed messages per replica. Default: 50. Lower values = more aggressive scaling. Teams often set this too low (5-10), resulting in over-provisioning.
- `offsetResetPolicy: latest`: Start from the latest offset on first deployment. Without this, KEDA counts from the beginning of the topic history on first run, causing a scale-up spike.
- `minReplicaCount: 0`: Enables scale-to-zero. Use in dev to save costs. Set to 1 in staging/prod.

## HTTP Scaler

Use for services with bursty HTTP traffic that should scale to zero in non-production environments.

**Requirements:** Install the KEDA HTTP add-on separately:
```bash
helm install http-add-on kedacore/keda-add-ons-http -n keda
```

**Known limitations:**
- WebSocket upgrades are not supported
- Cold start latency: approximately 2-3 seconds from zero to first response (Node.js services)
- Not recommended for production services with sub-second latency SLOs

## TriggerAuthentication (IRSA)

All AWS-based scalers use pod identity via IRSA. No static credentials.

See `auth/sqs-trigger-auth.yaml` for the TriggerAuthentication template.

## Helm Chart

Use the Helm chart to deploy a ScaledObject with configurable scaler type:

```bash
# SQS scaler
helm install my-service-scaler ./keda/helm/scaledobject \
  --namespace my-team-prod \
  --set scalerType=sqs \
  --set deployment.name=my-service \
  --set sqs.queueURL=https://sqs.eu-west-1.amazonaws.com/123456789/my-queue \
  --set sqs.triggerAuthName=my-service-keda-auth

# Kafka scaler
helm install my-service-scaler ./keda/helm/scaledobject \
  --namespace my-team-dev \
  --set scalerType=kafka \
  --set deployment.name=my-service \
  --set kafka.bootstrapServers=kafka:9092 \
  --set kafka.consumerGroup=my-consumer-group \
  --set kafka.topic=my-topic \
  --set minReplicas=0
```
