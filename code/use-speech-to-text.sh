#!/bin/bash

# **************** Global variables

source ./code/.env

export OAUTHTOKEN=""
export IBMCLOUD_APIKEY=$APIKEY
export T_RESOURCEGROUP=$RESOURCE_GROUP
export T_REGION=$REGION
export S2T_APIKEY=""
export S2T_URL=""
export CUSTOM_MODEL_JSON=mymodel-1.json
export CUSTOM_MODEL_ID_JSON=customization_id.json
export SIMPLE_AUDIO_FLAC=my-s2t-audio.flac

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

function getAllModels () {
   curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/models"
}

function getEnUSBroadbandModel () {
   curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/models" | grep "en-US_BroadbandModel"
}

function sendDefaultAudio () {
   curl -X POST -u "apikey:$S2T_APIKEY" --header "Content-Type: audio/flac" --data-binary @"$ROOTFOLDER/code/$SIMPLE_AUDIO_FLAC" "$S2T_URL/v1/recognize"
}

# ********************************
# Create a custom language model by extending an existing model
# "en-US_BroadbandModel"

function createCustomLanguageModel () {
    export customization_id=$(curl -X POST -u "apikey:$S2T_APIKEY" --header "Content-Type: application/json" --data  @$ROOTFOLDER/code/$CUSTOM_MODEL_JSON "$S2T_URL/v1/customizations")
    echo "customization_id: $customization_id"
    echo $customization_id > $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON
}

function deleteCustomLanguageModel () {
    export CUSTOM_MODEL_ID_JSON=customization_id.json
    export customization_id=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON | jq '.customization_id' | sed 's/"//g')
    echo  "Delete 'customization_id': $customization_id"
    curl -X DELETE -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id"
}

# **********************************************************************************
# Execution
# **********************************************************************************

loginIBMCloud

getToken

getEnUSBroadbandModel

#createCustomLanguageModel
#deleteCustomLanguageModel

sendDefaultAudio
