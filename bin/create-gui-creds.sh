#!/bin/bash

USERNAME=$1
PASSWORD=$2
EPPN=$3
METHOD=$4
CLOUD=$5
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$EPPN" ] || [ -z "$METHOD" ] || [ -z "$CLOUD" ]
then
    echo "Usage: $0 Username Password EPPN METHOD cloud"
    echo "without openid the default is shibboleth"
    echo "for cloud use \"adler\" or \"conte\" default is \"sullivan\""
    exit 1
fi

ssh ubuntu@www.opensciencedatacloud.org "/var/www/tukey/tukey-middleware/tools/with_venv.sh python /var/www/tukey/tukey-middleware/create_tukey_user.py $CLOUD $METHOD $EPPN $USERNAME $PASSWORD"
