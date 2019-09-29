# contino

**Clodformation deployment steps**
- Install AWS CLI
``` aws configure ```
- Create a Bucket 
 ```aws s3 mb s3://continotestsydney```
- Deploy cloudformation vai aws cli
``` aws cloudformation deploy --template-file cf-template1.yaml --stack-name testsydney4 --s3-bucket continotestsydney --capabilities CAPABILITY_IAM --parameter-overrides BucketName=continotestsydney4```

> Uploading to d1a351758efa8383877b7345d8d3abb0.template  11728 / 11728.0  (100.00%)
> Waiting for changeset to be created..
> Waiting for stack create/update to complete
> Successfully created/updated stack - testsydney4
