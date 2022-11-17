# watson-s2t-invocation

### Configure .env

```sh
cp ./code/.env-template ./code/.env
```

### Set the correct values in the `.env` file

```sh
ROOTFOLDER="YOUR_PATH"
RESOURCE_GROUP="default"
REGION="us-south"
APIKEY="YOUR_IBMCLOUD_APIKEY"
S2T_SERVICE_INSTANCE_NAME="YOUR_S2T_SERVICE_NAME"
```

### Invoke

```sh
sh code/use-speech-to-text.sh
```