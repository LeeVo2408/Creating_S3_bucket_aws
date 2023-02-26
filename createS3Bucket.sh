#!/bin/bash

read -r -p "Enter the name of the bucket:" bucket_name
read -r -p "Enter Profile number:" profile
website_directory='./awsfiles'
#read -r -p "Region:" Region 

# 1. Create a new bucket 
aws s3 mb \
        "s3://$bucket_name/" \
        --profile $profile\

sleep 2

echo "Enable public access" 

# 2. Enable public access
aws s3api put-public-access-block \
  --profile $profile \
  --bucket $bucket_name \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# 3. Update the bucket policy for public read access:
aws s3api put-bucket-policy \
  --profile $profile \
  --bucket $bucket_name \
  --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [
      {
          \"Sid\": \"PublicReadGetObject\",
          \"Effect\": \"Allow\",
          \"Principal\": \"*\",
          \"Action\": \"s3:GetObject\",
          \"Resource\": \"arn:aws:s3:::$bucket_name/*\"
      }
  ]
}"



# 4. Enable the s3 bucket to host an `index` and `error` html page
mkdir -p ./awsfiles
echo "Creating awsfiles directory"
touch ./awsfiles/index.html
echo "Creating index.html file"

cat > ./awsfiles/index.html << EOF
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title>My Website Home Page</title>
</head>
<body>
  <h1>Welcome to my website</h1>
  <p>Now hosted on Amazon S3!</p>
</body>
</html>

EOF

aws s3 website "s3://$bucket_name" \
  --profile $profile \
  --index-document index.html

# # 5. Upload you website
aws s3 sync \
  --profile $profile \
  $website_directory "s3://$bucket_name/" 
