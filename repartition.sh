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
