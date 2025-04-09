# Command to compress  
zip revision-v2 index.html appspec.yml update_app.sh restart_app.sh
# Create a bucket
# Use the following script under s3 folder
 ./create-bucket my-code-deploy-bucket-xyz
 # Command to upload into s3 bucket 
 aws s3 cp revision-v2.zip  s3://my-code-deploy-bucket-xyz/revisiones/v2.zip
 (zip format is required in deployment of codeDeploy when we use s3 as revison location)