#!/bin/bash
# Rescale script for building a SIF file
source .config
APITOKEN=$RESCALE_API_KEY
#APIBASEURL="https://platform.rescale.com"
#NIGHTLYBUILDDIR=hMJcW

echo ${APIBASEURL}

#(Optional) Manually upload files
  #output=$(rescale-cli -X ${APIBASEURL} upload -f hexagon_software.def -T auto_build_singularity.def -e)

  ##Get the file ID for the file just uploaded
  #DEF_FILE_ID=$(echo ${output} | sed 's/.*platform. //' | jq '.files[0].id' | tr -d '"')

  ##Add this file name to RESCALE_EXISTING_FILES
  #sed -i.bak "s/DEF_FILE_ID/$DEF_FILE_ID/" submit.sh
exit
#All files in this directory will be zipped up as part of the job
rescale-cli submit -i submit.sh > logs.txt

#Get Job ID
JOBIDTEMP=$(grep -rnw logs.txt -e 'Job.*: Saved' | sed 's/.*Job //')
JOBID=${JOBIDTEMP%:*}
echo Job ID: $JOBID

#Check status of job
STATUS=$(rescale-cli status -j $JOBID)
#Looking for response: The status of job <jobid> is Completed
bContinue=true
while $bContinue
do
  echo polling...\\r
  STATUS=$(rescale-cli status -j $JOBID)
  if [[ "$STATUS" == *"Completed" ]]; then
    bContinue=false
  fi
  echo waiting until next poll interval...\\r
  sleep 30s
done

echo [Update] $STATUS

#Get the File ID for the generated SIF file
FILEID=$(curl --location --request GET "${APIBASEURL}/api/v2/jobs/${JOBID}/files/" \
--header "Authorization: Token ${APITOKEN}" \
--header 'Content-Type: application/json' | jq '.results[] | select(.name|test("actran.*sif")) | .id' | tr -d '"')
echo ${FILEID} > .fileid

#Move the file to the shared file directory
curl --location --request POST "${APIBASEURL}/api/v3/file-folders/$NIGHTLYBUILDDIR/files/" \
--header "Authorization: Token ${APITOKEN}" \
--header 'Content-Type: application/json' \
--data-raw '{"ids":["'$FILEID'"]}'

#Set the file as an Input
curl --location --request POST "${APIBASEURL}/api/v3/files/bulk/type-change/" \
--header "Authorization: Token ${APITOKEN}" \
--header 'Content-Type: application/json' \
--data-raw '{"ids":["'$FILEID'"],"type":1}'

