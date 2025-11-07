#!/usr/bin/env bash
set -euo pipefail
if [ ! -f ops/deploy.vars ]; then
  echo "ops/deploy.vars not found. Copy ops/deploy.vars.template -> ops/deploy.vars and edit it."
  exit 1
fi
source ops/deploy.vars

echo "Stopping EC2: $EC2_INSTANCE_ID"
if [ -n "$EC2_INSTANCE_ID" ] && [ "$EC2_INSTANCE_ID" != "<EC2_INSTANCE_ID>" ]; then
  aws ec2 stop-instances --instance-ids $EC2_INSTANCE_ID --region $AWS_REGION
fi

if [ -n "$BACKEND_DIST_ID" ] && [ "$BACKEND_DIST_ID" != "<BACKEND_DIST_ID>" ]; then
  echo "Disabling and deleting backend CloudFront: $BACKEND_DIST_ID"
  ETAG=$(aws cloudfront get-distribution-config --id $BACKEND_DIST_ID --query 'ETag' --output text)
  aws cloudfront get-distribution-config --id $BACKEND_DIST_ID --output json > /tmp/dist-config.json
  jq '.DistributionConfig.Enabled=false' /tmp/dist-config.json > /tmp/dist-config-disabled.json
  aws cloudfront update-distribution --id $BACKEND_DIST_ID --if-match "$ETAG" --distribution-config file:///tmp/dist-config-disabled.json
  sleep 5
  ETAG=$(aws cloudfront get-distribution-config --id $BACKEND_DIST_ID --query 'ETag' --output text)
  aws cloudfront delete-distribution --id $BACKEND_DIST_ID --if-match "$ETAG" || true
fi

read -p "Empty S3 bucket $FRONTEND_BUCKET? (y/N) " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  aws s3 rm s3://$FRONTEND_BUCKET --recursive
fi

echo "Cleanup script finished."
