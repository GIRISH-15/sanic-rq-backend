#!/usr/bin/env bash
set -euo pipefail
# Usage: source ops/deploy.vars (after copying template to deploy.vars and editing)
if [ ! -f ops/deploy.vars ]; then
  echo "ops/deploy.vars not found. Copy ops/deploy.vars.template -> ops/deploy.vars and edit it."
  exit 1
fi
source ops/deploy.vars

echo "1) Build frontend (run in frontend repo) and upload to S3:"
echo "   export REACT_APP_BACKEND_URL=https://$BACKEND_CF_DOMAIN"
echo "   npm ci && npm run build"
echo "   aws s3 sync build/ s3://$FRONTEND_BUCKET/ --delete"

echo
echo "2) SSH to EC2 and start backend (copy/paste the command below and run it):"
echo "ssh -i $KEY_PEM_PATH ec2-user@$EC2_PUBLIC_IP"
echo
echo "Once on EC2 run these commands:"
echo "  cd /home/ec2-user || cd ~"
echo "  git clone https://github.com/GIRISH-15/sanic-rq-backend.git || (cd sanic-rq-backend && git pull)"
echo "  cd sanic-rq-backend"
echo "  cp .env.example .env   # edit .env on EC2 with SECRET_TOKEN etc (do NOT commit)"
echo "  docker compose up -d --build"
echo "  docker ps"
echo "  curl http://localhost:8000/health"
