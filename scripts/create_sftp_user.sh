#!/bin/bash
USER=$1
PASS=$2
BUCKET="dev"

docker exec minio-sftp sh -c "
mc alias set myminio http://localhost:9008 admin ********** >/dev/null 2>&1
mc mb myminio/$BUCKET >/dev/null 2>&1
cat > /tmp/$USER-policy.json <<EOF
{
  \"Version\": \"2012-10-17\",
  \"Statement\": [
    {\"Action\": [\"s3:GetBucketLocation\",\"s3:ListBucket\"],\"Effect\":\"Allow\",\"Resource\":[\"arn:aws:s3:::$BUCKET\"]},
    {\"Action\": [\"s3:GetObject\",\"s3:PutObject\",\"s3:DeleteObject\"],\"Effect\":\"Allow\",\"Resource\":[\"arn:aws:s3:::$BUCKET/*\"]}
  ]
}
EOF
mc admin policy create myminio $USER-policy /tmp/$USER-policy.json >/dev/null 2>&1
mc admin user add myminio $USER $PASS >/dev/null 2>&1
mc admin policy attach myminio $USER-policy --user $USER >/dev/null 2>&1
echo \"✅ SFTP user '$USER' created with bucket '$BUCKET'.\"
"

