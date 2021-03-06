#!/bin/bash

if [ -e /etc/osdc_cloud_accounting/settings.sh ]
then
    source  /etc/osdc_cloud_accounting/settings.sh
else
    echo "$0 Error: can not locate /etc/osdc_cloud_accounting/settings.sh "
    exit 1
fi

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

if [ "$ACCTCREATION_SSHKEY" == "" ] 
then
	/var/www/tukey/tukey_middleware/tools/with_venv.sh python /var/www/tukey/tukey_middleware/tools/create_tukey_user.py  $CLOUD $METHOD $EPPN $USERNAME $PASSWORD # &>/dev/null
else 
	ssh -i $ACCTCREATION_SSHKEY ubuntu@www.opensciencedatacloud.org "/var/www/tukey/tukey_middleware/tools/with_venv.sh python /var/www/tukey/tukey_middleware/tools/create_tukey_user.py  $CLOUD $METHOD $EPPN $USERNAME $PASSWORD"
fi

##if [ "$FORCE_ACCTCREATION_SSHKEY" ] 
#if [ "$METHOD" == "shibboleth-pdc-none-nih-idp" ]
#then
#    METHOD="shibboleth"
#    CLOUD="pdc"
#	ssh -i $FORCE_ACCTCREATION_SSHKEY ubuntu@www.opensciencedatacloud.org "/var/www/tukey/tukey_middleware/tools/with_venv.sh python /var/www/tukey/tukey_middleware/tools/create_tukey_user.py  $CLOUD $METHOD $EPPN $USERNAME $PASSWORD"
#elif [ "$METHOD" == "openid-pdc-none-nih-idp" ]
#then
#    METHOD="openid"
#    CLOUD="pdc"
#	ssh -i $FORCE_ACCTCREATION_SSHKEY ubuntu@www.opensciencedatacloud.org "/var/www/tukey/tukey_middleware/tools/with_venv.sh python /var/www/tukey/tukey_middleware/tools/create_tukey_user.py  $CLOUD $METHOD $EPPN $USERNAME $PASSWORD"
#elif [ "$ACCTCREATION_SSHKEY" == "" ] 
#then
#	/var/www/tukey/tukey_middleware/tools/with_venv.sh python /var/www/tukey/tukey_middleware/tools/create_tukey_user.py  $CLOUD $METHOD $EPPN $USERNAME $PASSWORD # &>/dev/null
#else 
#	ssh -i $ACCTCREATION_SSHKEY ubuntu@www.opensciencedatacloud.org "/var/www/tukey/tukey_middleware/tools/with_venv.sh python /var/www/tukey/tukey_middleware/tools/create_tukey_user.py  $CLOUD $METHOD $EPPN $USERNAME $PASSWORD"
#fi
