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

**Update Lambda Function to capture sentiment**
```
def get_sentiment(response):
    keys = ['POSITIVE','NEGATIVE','MIXED']
    upperres = response.upper()
    reslist = upperres.split(" ")
    sentiment = list(set(reslist) & set(keys))
    if len(sentiment) > 0:
        sentiment = sentiment[0]
    else:
        sentiment = "NEUTRAL"
        
    return str(sentiment) ```
 - This function will check the sentiment key words and return the sentiment word if found one, otherwise default to NEUTRAL. 
 - If there is more than one sentiment then first in the list considered as the sentiment 
