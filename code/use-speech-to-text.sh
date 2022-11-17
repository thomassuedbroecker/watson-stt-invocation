#!/bin/bash

# **************** Global variables

source ./code/.env

export OAUTHTOKEN=""
export IBMCLOUD_APIKEY=$APIKEY
export T_RESOURCEGROUP=$RESOURCE_GROUP
export T_REGION=$REGION
export S2T_APIKEY=""
export S2T_URL=""

# **********************************************************************************
# Functions definition
# **********************************************************************************

function loginIBMCloud () {
    ibmcloud login  --apikey $IBMCLOUD_APIKEY
    ibmcloud target -g $T_RESOURCEGROUP
    ibmcloud target -r $T_REGION
    ibmcloud target
}

function getToken() {
    TEMPFILE=temp-s2t.json
    REQUESTMETHOD=POST
    export OAUTHTOKEN=$(ibmcloud iam oauth-tokens | awk '{print $4;}')
    echo "OAUTHTOKEN: $OAUTHTOKEN"
    
    ibmcloud resource service-keys --instance-name $S2T_SERVICE_INSTANCE_NAME
    ibmcloud resource service-keys --instance-name $S2T_SERVICE_INSTANCE_NAME --output json
    ibmcloud resource service-keys --instance-name $S2T_SERVICE_INSTANCE_NAME --output json > $ROOTFOLDER/code/$TEMPFILE
    export S2T_APIKEY=$(cat $ROOTFOLDER/code/$TEMPFILE | jq '.[0].credentials.apikey' | sed 's/"//g')
    export S2T_URL=$(cat $ROOTFOLDER/code/$TEMPFILE | jq '.[0].credentials.url' | sed 's/"//g')
}

function getModels () {
   curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/models"
}

# **********************************************************************************
# Execution
# **********************************************************************************

loginIBMCloud

getToken

getModels
