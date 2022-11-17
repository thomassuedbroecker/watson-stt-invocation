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
export DRUMS_TEXT=drums.txt
export DRUMS_AUDIO=drums.flac
export CORPUS_NAME=drums1

# **********************************************************************************
# Functions definition
# **********************************************************************************

function loginIBMCloud () {
    ibmcloud login  --apikey $IBMCLOUD_APIKEY
    ibmcloud target -g $T_RESOURCEGROUP
    ibmcloud target -r $T_REGION
    ibmcloud target
}

function getAPIKey() {
    TEMPFILE=temp-s2t.json
    REQUESTMETHOD=POST
    
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

#*********************************
#        Customized models
#*********************************

function getAllCustomizedModels () {
   curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations"
}

# -------------------------
# Create a custom language model by extending an existing model
# "en-US_BroadbandModel"
# -------------------------

function createCustomLanguageModel () {
    export customization_id=$(curl -X POST -u "apikey:$S2T_APIKEY" --header "Content-Type: application/json" --data  @$ROOTFOLDER/code/$CUSTOM_MODEL_JSON "$S2T_URL/v1/customizations")
    echo ""
    echo "customization_id: $customization_id"
    echo $customization_id > $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON
}

function deleteCustomLanguageModel () {
    export CUSTOM_MODEL_ID_JSON=customization_id.json
    export customization_id=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON | jq '.customization_id' | sed 's/"//g')
    echo ""
    echo  "Delete 'customization_id': $customization_id"
    curl -X DELETE -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id"
}

#*********************************
#        Corpora
#*********************************

function createCorpora () {
    export customization_id=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON | jq '.customization_id' | sed 's/"//g')
    curl -X POST -u "apikey:$S2T_APIKEY" --data-binary @"$ROOTFOLDER/code/$DRUMS_TEXT"  "$S2T_URL/v1/customizations/$customization_id/corpora/$CORPUS_NAME"

    STATUS='being_processed'
    TIME=10

    while [ "$STATUS" != 'analyzed' ]; do
        sleep 10
        RESPONSE=$(curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id/corpora/$CORPUS_NAME")
        echo "Response: $RESPONSE"
        STATUS=$(echo $RESPONSE | sed -e 's/.*\"status\": \"\([^\"]*\)\".*/\1/')
        echo "Status: %-15s ( %d )\n" "$STATUS" $TIME
        let "TIME += 10"
    done
}

function listCorpora () {
    export customization_id=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON | jq '.customization_id' | sed 's/"//g')
    curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id/corpora"
}

function deleteCorpora () {
    export customization_id=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON | jq '.customization_id' | sed 's/"//g')
    echo ""
    echo "Delete 'customization_id' 'corpus_name': $customization_id $CORPUS_NAME"
    curl -X DELETE -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id/corpora/$CORPUS_NAME"
}

#*********************************
#        Train the model
#  Information: https://cloud.ibm.com/docs/speech-to-text?topic=speech-to-text-languageCreate#trainModel-language
#*********************************

function trainCustomLanguageModel () {
    export customization_id=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON | jq '.customization_id' | sed 's/"//g')
    echo ""
    echo "Train ..."

    curl -X POST -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id/train"
    
    STATUS='pending'
    TIME=10

    while [ "$STATUS" != 'available' ]; do
        sleep 10
        RESPONSE=$(curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id")
        echo "Response: $RESPONSE"
        STATUS=$(echo $RESPONSE | sed -e 's/.*\"status\": \"\([^\"]*\)\".*/\1/')
        echo "Status ($STATUS)"
        echo "Status: %-15s ( %d )\n" "$STATUS" $TIME
        let "TIME += 10"
    done

    curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id/words"
    curl -X GET -u "apikey:$S2T_APIKEY" "$S2T_URL/v1/customizations/$customization_id"
}

#*********************************
#       Verify the model
#*********************************

function verifyCustomLanguageModel () {
   export customization_id=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON | jq '.customization_id' | sed 's/"//g')
   export basic_model=$(cat $ROOTFOLDER/code/$CUSTOM_MODEL_JSON | jq '.base_model_name' | sed 's/"//g')
   
   echo "customization_id: $customization_id"
   echo "basic_model: $basic_model"
   echo ""
   echo "Test audio ..."
   curl -X POST -u "apikey:$S2T_APIKEY" --header "Content-Type: audio/flac" --data-binary @"$ROOTFOLDER/code/$DRUMS_AUDIO" "$S2T_URL/v1/recognize?model=${basic_model}&language_customization_id=$customization_id"
}

function customizationFlow() {

    echo "#*******************"
    echo "# Create and train a Custom Language Model"
    echo "#*******************"
    createCustomLanguageModel
    getAllCustomizedModels
    createCorpora
    listCorpora
    trainCustomLanguageModel
    echo "#*******************"
    echo "# Verify a trained model by using an audio"
    echo "#*******************"
    verifyCustomLanguageModel

}

function deleteAll () {
   deleteCorpora
   deleteCustomLanguageModel
   rm $ROOTFOLDER/code/$CUSTOM_MODEL_ID_JSON
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "#*******************"
echo "# Connect to IBM Cloud and"
echo "# get the Speech to Text API key"
echo "#*******************"

loginIBMCloud

getAPIKey

echo "#*******************"
echo "# Verify a basic audio"
echo "#*******************"

#sendDefaultAudio

#getEnUSBroadbandModel

echo "#*******************"
echo "# Delete the created customizations"
echo "#*******************"

deleteAll

echo "#*******************"
echo "# Customization flow"
echo "#*******************"

customizationFlow




