# How to write a Bash Script to configure a static websit on Amazon S3.

Ensuring that you have [authenticated to AWS with CLI](https://uts-edu.atlassian.net/wiki/spaces/CET/pages/49678450/AWS+using+Session+Manager+for+SSH+PowerShell#Authenticating-to-AWS-with-CLI) before starting the tutorial.

If you have done so, please also login to your account via SSO (aws sso login --profile "your profile number-./.aws/config ")

## Step 1: Create a bucket 
```
read -r -p "Enter the name of the bucket:" bucket_name
read -r -p "Enter Profile number:" profile
website_directory='./awsfiles'
#read -r -p "Region:" Region 

# 1. Create a new bucket 
aws s3 mb \  $profile\
```

'read -r -p' allows you to insert your own profile name and creating bucket with your prefered name. 
>- r: Disable blackslashes to escape character
>- p: <prompt> Outputs the prompt string before reading user input 


## Step 2. Enable public access
```
aws s3api put-public-access-block \
  --profile $profile \
  --bucket $bucket_name \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```
'aws s3api put-public-access-block' set the bucet to publicly accessable. 

**NOTE: The bucket is not publiclly accessible by default**

## Step 3. Update the bucket policy for public read access:
```
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
```
'aws s3api put-bucket-policy' allows you to create a bucket policy. In this specific case, anyone can get the object of the bucket.

**NOTE: Ensure that the policy has to be written in JSON.**


## 4. Enable the s3 bucket to host an `index` html
creating a html file locally in your computer.

```
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

```

This creates an index.html file hosted locally in your computer. 
>`./awsfiles/index.html`. 

You can change the website title if you want. Feel free to replace it with any index document you have. 

## Step 5: Upload your webseite.
```
aws s3 sync \
  --profile $profile \
  $website_directory "s3://$bucket_name/"
  ```
'aws s3 sync' uploads your website in the S3 bucket. `$Website_directory`  navigate to the local hosted index.html file. 
