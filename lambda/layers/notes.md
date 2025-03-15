## ZIP folder
zip -r facker_layer  .

## Upload to a s3 bucket
./upload_to_s3.sh  ../../../lambda/python/facker_layer.zip my-awesome-lambda-layers

## publish a layer


aws lambda publish-layer-version \
  --layer-name faker-layer \
  --description "My Faker  layer" \
  --content S3Bucket=my-awesome-lambda-layers,S3Key=facker_layer.zip \
  --compatible-runtimes python3.12\
  --license-info "MIT"