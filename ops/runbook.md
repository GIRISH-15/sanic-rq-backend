ONE-STOP RUNBOOK (short)
1. Local: copy ops/deploy.vars.template -> ops/deploy.vars and EDIT it with real values.
2. Local (frontend): export REACT_APP_BACKEND_URL and build + aws s3 sync.
3. Local: run ops/deploy.sh to see SSH command and instructions.
4. EC2: SSH, clone repo, copy .env.example to .env, edit .env with SECRET_TOKEN, then docker compose up -d --build.
5. Local: aws cloudfront create-invalidation --distribution-id $FRONTEND_DIST_ID --paths "/*"
6. Verify E2E and create AMI: aws ec2 create-image --instance-id $EC2_INSTANCE_ID --name "sanic-backup-$(date +%F)" --no-reboot
