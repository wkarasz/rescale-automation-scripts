#!/bin/bash

# Submit a multi-software job (BYO Singularity + X)
source .config

APITOKEN=$RESCALE_API_KEY
INPUTDAT=MCLEsm		# nacelle_case1.dat
FILEID=$(cat .fileid)  	# Actran SIF file created in rescale_pipeline.sh

### Launch a multi-tile job via the API v3
# POST https://platform.rescale.com/api/v3/jobs/
# {"name":"Actran Singularity Example v1 (Cloned)","description":"","cidrRule":"108.27.231.172/32","clonedFrom":"SJEzXb","archiveFilters":[],"jobanalyses":[{"analysis":{"code":"msc_nastran_e2e_desktop","version":"2021.2"},"command":"","flags":{"igCv":true,"runForever":true},"hardware":{"coresPerSlot":2,"slots":1,"walltime":3,"type":"interactive","coreType":{"code":"emerald_max"}},"inputFiles":[{"id":"dbeRMi","decompress":true},{"id":"mDXCXi","decompress":true},{"id":"uPhhYi","decompress":true},{"id":"CTGeRj","decompress":true}],"onDemandLicenseSeller":{"code":"rescale","name":"Rescale"},"envVars":null},{"analysis":{"code":"user_included_singularity_container_e2e_desktop","version":"3.8.0"},"command":"","flags":{"igCv":true,"runForever":true},"hardware":{"coresPerSlot":2,"slots":1,"walltime":3,"type":"interactive","coreType":{"code":"emerald_max"}},"inputFiles":[],"onDemandLicenseSeller":null,"envVars":null}],"paramFile":null,"jobvariables":[],"isLowPriority":false,"billingPriorityValue":"INSTANT","isTemplateDryRun":false,"inputFileParseTask":"","isTemplate":false,"templatedFrom":null}

# Create the job (but don't start)
output=$(curl --location --request POST "${APIBASEURL}/api/v2/jobs/" \
--header "Authorization: Token ${APITOKEN}" \
--header "Content-Type: application/json" \
--data-raw '{ 
  "name": "auto-launched batch job-'$(date +'%Y%m%d')'",
  "jobanalyses": [
    {
      "analysis": {
        "code": "user_included_singularity_container",
        "version": "3.8.0"
      },
      "command": "cd work/shared; singularity exec act*.sif actran --np=2 --threads=4 --inputfile=nacelle_case1.dat -m 1000 -p matrix --machinefile=$HOME/machinefile",
      "flags": {
        "igCv": true
      },
      "hardware": {
        "coreType": "emerald",
        "coresPerSlot": 1,
        "walltime": 1,
        "type": "compute"
      },
      "inputFiles": [
        {"id": "'$FILEID'"},
        {"id": "'$INPUTDAT'"}
      ]

    },
    {
      "analysis": {
        "code": "msc_nastran",
        "version": "2021.2"
      },
      "command": "cd work/shared; singularity exec act*.sif actran --np=2 --threads=4 --inputfile=nacelle_case1.dat -m 1000 -p matrix --machinefile=$HOME/machinefile",
      "flags": {
        "igCv": true
      },
      "hardware": {
        "coreType": "emerald",
        "coresPerSlot": 1,
        "walltime": 1,
        "type": "compute"
      },
      "onDemandLicenseSeller": {
        "code": "rescale",
        "name": "Rescale"
      }

    }
  ]
}')

echo $output
echo 
JOBID=$(echo $output | jq .id | tr -d '"')
echo JobID: ${JOBID}

# Launch the job
curl -X POST -H "Authorization: Token ${APITOKEN}" \
${APIBASEURL}/api/v2/jobs/${JOBID}/submit/

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
