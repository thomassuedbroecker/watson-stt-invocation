# Watson STT invocation

This project contains a bash script automation example for the IBM Cloud Watson Speech to Text service.

The automation contains two flows:

1. Basic usage for extract the text from an audio saved in [FLAC format](https://simple.wikipedia.org/wiki/FLAC) using a base language model.
2. Customization of an existing language model for a domain in this example for drums ;-) 

_Note:_ If you record your own voice for example in a [M4A format](https://en.wikipedia.org/wiki/MP4_file_format) here is a possibiltiy to convert M4A to [FLAC format](https://simple.wikipedia.org/wiki/FLAC) for free with [Converio](https://convertio.co/m4a-flac/).

### Prerequsites

* [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started) installed
* A [Watson Text to Speech](https://cloud.ibm.com/catalog/services/speech-to-text#about) service with an [Plus plan](https://cloud.ibm.com/docs/billing-usage?topic=billing-usage-changing&interface=ui) is created.
* Install the cURL command line on the local computer

### Clone the project

```sh
git clone https://github.com/thomassuedbroecker/watson-s2t-invocation.git
cd watson-s2t-invocation
```

### Configure the `.env` file

```sh
cp ./code/.env-template ./code/.env
```

### Set the correct values in the `.env` file

* [Create an IBM Cloud APIKEY](https://www.ibm.com/docs/en/app-connect/containers_cd?topic=servers-creating-cloud-api-key)

```sh
ROOTFOLDER="YOUR_PATH"
RESOURCE_GROUP="default"
REGION="us-south"
APIKEY="YOUR_IBMCLOUD_APIKEY"
S2T_SERVICE_INSTANCE_NAME="YOUR_S2T_SERVICE_NAME"
```

### Invoke the bash automation

```sh
sh code/use-speech-to-text.sh
```

* Example output

```sh
#*******************
# Customization flow
#*******************
#------------------
# Create and train a Custom Language Model
#------------------
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   160  100    61  100    99    170    277 --:--:-- --:--:-- --:--:--   458

customization_id: {"customization_id": "7868e363-4afa-4d64-96fd-c506774eebca"}
{"customizations": [{
   "owner": "d3443a47-877c-496d-95b9-f62bce50bb38",
   "base_model_name": "en-US_BroadbandModel",
   "customization_id": "7868e363-4afa-4d64-96fd-c506774eebca",
   "dialect": "en-US",
   "versions": ["en-US_BroadbandModel.v2020-01-16"],
   "created": "2022-11-18T13:32:44.945Z",
   "name": "MyDrums-1",
   "description": "MyDrums-demo",
   "progress": 0,
   "language": "en-US",
   "updated": "2022-11-18T13:32:44.945Z",
   "status": "pending"
}]}
{}
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   104  100   104    0     0    319      0 --:--:-- --:--:-- --:--:--   330
Response: {
   "out_of_vocabulary_words": 1,
   "total_words": 43,
   "name": "drums1",
   "status": "analyzed"
}
Status: %-15s ( %d )
 analyzed 10
{"corpora": [{
   "out_of_vocabulary_words": 1,
   "total_words": 43,
   "name": "drums1",
   "status": "analyzed"
}]}

Train ...
{}
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   449  100   449    0     0   1537      0 --:--:-- --:--:-- --:--:--  1586
Response: {
   "owner": "d3443a47-XXX-XXXX-95b9-f62bce50bb38",
   "base_model_name": "en-US_BroadbandModel",
   "customization_id": "7868e363-XXX-XXXX-96fd-c506774eebca",
   "dialect": "en-US",
   "versions": ["en-US_BroadbandModel.v2020-01-16"],
   "created": "2022-11-XXX-XXXX",
   "name": "MyDrums-1",
   "description": "MyDrums-demo",
   "progress": 0,
   "language": "en-US",
   "updated": "2022-11-XXX-XXXX",
   "status": "training"
}
Status (training)
Status: %-15s ( %d )
 training 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   452  100   452    0     0   1293      0 --:--:-- --:--:-- --:--:--  1333
Response: {
   "owner": "d3443a47-XXX-XXXX-95b9-f62bce50bb38",
   "base_model_name": "en-US_BroadbandModel",
   "customization_id": "7868e363-XXX-XXXX-96fd-c506774eebca",
   "dialect": "en-US",
   "versions": ["en-US_BroadbandModel.v2020-01-16"],
   "created": "2022-11-XXX-XXXX",
   "name": "MyDrums-1",
   "description": "MyDrums-demo",
   "progress": 100,
   "language": "en-US",
   "updated": "2022-11-XXX-XXXX",
   "status": "available"
}
Status (available)
Status: %-15s ( %d )
 available 20
{"words": [{
   "display_as": "paradiddles",
   "sounds_like": ["paradiddles"],
   "count": 1,
   "source": ["drums1"],
   "word": "paradiddles"
}]}
{
   "owner": "d3443a47-XXX-XXXX-95b9-f62bce50bb38",
   "base_model_name": "en-US_BroadbandModel",
   "customization_id": "7868e363-XXX-XXXX-96fd-c506774eebca",
   "dialect": "en-US",
   "versions": ["en-US_BroadbandModel.v2020-01-16"],
   "created": "2022-11-XXX-XXXX",
   "name": "MyDrums-1",
   "description": "MyDrums-demo",
   "progress": 100,
   "language": "en-US",
   "updated": "2022-11-XXX-XXXX",
   "status": "available"
}
#------------------
# Verify a trained model by using an audio
#------------------
customization_id: 7868e363-XXX-XXXX-96fd-c506774eebca
basic_model: en-US_BroadbandModel

Test audio ...
 {
   "result_index": 0,
   "results": [
      {
         "final": true,
         "alternatives": [
            {
               "transcript": "it's great to play the drums The hi hat is something very special ",
               "confidence": 0.98
            }
         ]
      },
      {
         "final": true,
         "alternatives": [
            {
               "transcript": "it forms the basis for many rhythms syncopations are sometimes distributed with paradiddles and they are creating a fantastic rhythm together with the snare and the bass drum and a splash ",
               "confidence": 0.94
            }
         ]
      }
   ]
}#*******************
# Basic flow
#*******************
{
   "result_index": 0,
   "results": [
      {
         "final": true,
         "alternatives": [
            {
               "transcript": "hi this is my test for Watson ",
               "confidence": 0.94
            }
         ]
      },
      {
         "final": true,
         "alternatives": [
            {
               "transcript": "speech to text ",
               "confidence": 0.99
            }
         ]
      },
      {
         "final": true,
         "alternatives": [
            {
               "transcript": "check it out ",
               "confidence": 0.99
            }
         ]
      }
   ]
} 
...
```
### Use API calls

* [recognize](https://cloud.ibm.com/apidocs/speech-to-text#recognize)
* [models](https://cloud.ibm.com/apidocs/speech-to-text#listmodels)
* [customizations - custom language models](https://cloud.ibm.com/apidocs/speech-to-text#createlanguagemodel)
* [corpora - custom](https://cloud.ibm.com/apidocs/speech-to-text#listcorpora)