# contino

## Cloudformation deployment steps
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

## Update Lambda Function to capture sentiment
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
        
    return str(sentiment) 
 ``` 
 - This function will check the sentiment key words and return the sentiment word if found one, otherwise default to NEUTRAL. 
 - If there is more than one sentiment then first in the list considered as the sentiment 

## Update Lambda to Send the Sentiment
```
 metricsResp = client.put_metric_data(
     Namespace='NewStarter',
     MetricData=[
      {
          'MetricName': candidate,
          'Timestamp': dateTimeObj,
          'Dimensions': [
                {
                    'Name': 'sentiment',
                    'Value': sentiment
                    },
              ],
          'Values': [
              1.0,
          ],
          'Counts': [
              1.0,
          ],
          'Unit': 'Count',
          'StorageResolution': 1
       },
     ]
   )
```
- Add a new dimension to capture ```sentiment``` from the response

##Update cloudwatch dashboard
```
{
                                       "metrics": [
                                           [ "NewStarter", "candicate", "sentiment", "MIXED", { "stat": "SampleCount", "period": 60 } ],
                                           [ "...", "NEGATIVE", { "stat": "SampleCount", "period": 60 } ],
                                           [ "...", "NEUTRAL", { "stat": "SampleCount", "period": 60 } ],
                                           [ "...", "POSITIVE", { "stat": "SampleCount", "period": 60 } ]
                                       ],
                                       "view": "timeSeries",
                                       "stacked": false,
                                       "region": "us-east-2",
                                       "liveData": true,
                                       "legend": {
                                           "position": "right"
                                       },
                                       "yAxis": {
                                           "left": {
                                               "showUnits": true
                                           }
                                       },
                                       "period": 300
                                   }
```

- Sample metric details are posted above

## Athena Query issue
It was identified that Athna was having issues to retrieve data due to the Glue table was not paritioned properly. While there many ways to address the issue, I've created quick shell script the create the missing paritions. 
```
#!/bin/bash
  
OLD_IFS=$IFS
IFS=$'\n'
table='newstartersentiment'
database='new-starter-db'

for i in $(aws s3 ls s3://conito/data/ --recursive | rev | awk '{print $1}'| awk -F '/' '{ $1="";print}'|rev)
do
        yearmonthdayhour=$( echo ${i} | awk '{ $1="";print}' | sed 's/ //g'  )
        URLp=$( echo ${i} | sed 's/ /\//g')

        DML="ALTER TABLE ${table} ADD PARTITION ( yearmonthdayhour = '${yearmonthdayhour}' ) LOCATION 's3://conito/${URLp}';"
        echo ${DML}
        aws athena start-query-execution --query-string "${DML}" --query-execution-context Database=${database}  --result-configuration "OutputLocation=s3://conito/output/"


done
IFS=$OLD_IFS
```
**There are much better ways to handle this, such as creating a lambda function to trigger when content created in the S3 bucket, went with quick dirty for the timebeing**

# Testing 
```
Execution log for request 706ba1a8-fe24-462b-9e27-922a33cdc2d9
Sun Sep 29 09:24:34 UTC 2019 : Starting execution for request: 706ba1a8-fe24-462b-9e27-922a33cdc2d9
Sun Sep 29 09:24:34 UTC 2019 : HTTP Method: POST, Resource Path: /response
Sun Sep 29 09:24:34 UTC 2019 : Method request path: {}
Sun Sep 29 09:24:34 UTC 2019 : Method request query string: {}
Sun Sep 29 09:24:34 UTC 2019 : Method request headers: {}
Sun Sep 29 09:24:34 UTC 2019 : Method request body before transformations: {
    "candidate": "candidate1",
    "response": "This is a positive response, time Sun 29 Sep  7:24pm AEST"
}
Sun Sep 29 09:24:34 UTC 2019 : Endpoint request URI: https://lambda.us-east-2.amazonaws.com/2015-03-31/functions/arn:aws:lambda:us-east-2:527960001713:function:conitostack-SentimentFunction-1LXFFKDJBOVTB/invocations
Sun Sep 29 09:24:34 UTC 2019 : Endpoint request headers: {x-amzn-lambda-integration-tag=706ba1a8-fe24-462b-9e27-922a33cdc2d9, Authorization=************************************************************************************************************************************************************************************************************************************************************************************************************************
Sun Sep 29 09:24:34 UTC 2019 : Endpoint request body after transformations: { "candidate": "candidate1", "response": "This is a positive response, time Sun 29 Sep  7:24pm AEST" }
Sun Sep 29 09:24:34 UTC 2019 : Sending request to https://lambda.us-east-2.amazonaws.com/2015-03-31/functions/arn:aws:lambda:us-east-2:527960001713:function:conitostack-SentimentFunction-1LXFFKDJBOVTB/invocations
Sun Sep 29 09:24:35 UTC 2019 : Received response. Status: 200, Integration latency: 1640 ms
Sun Sep 29 09:24:35 UTC 2019 : Endpoint response headers: {Date=Sun, 29 Sep 2019 09:24:35 GMT, Content-Type=application/json, Content-Length=4, Connection=keep-alive, x-amzn-RequestId=75f78673-be32-4c50-8659-82e3468f2116, x-amzn-Remapped-Content-Length=0, X-Amz-Executed-Version=$LATEST, X-Amzn-Trace-Id=root=1-5d907852-6076ef956e163da4b39460e5;sampled=0}
Sun Sep 29 09:24:35 UTC 2019 : Endpoint response body before transformations: null
Sun Sep 29 09:24:35 UTC 2019 : Method response body after transformations: {}
Sun Sep 29 09:24:35 UTC 2019 : Method response headers: {X-Amzn-Trace-Id=Root=1-5d907852-6076ef956e163da4b39460e5;Sampled=0, Location=, Content-Type=application/json}
Sun Sep 29 09:24:35 UTC 2019 : Successfully completed execution
Sun Sep 29 09:24:35 UTC 2019 : Method completed with status: 200
```

### Athena Query result post creating partitions
This will prove the end to end functionality of the pipeline. 
```
select * from newstartersentiment;

Results

 	candidate	sentiment	datetime	yearmonthdayhour
 	candidate1	POSITIVE	2019-09-29 09:24:34.586	2019092909
```
