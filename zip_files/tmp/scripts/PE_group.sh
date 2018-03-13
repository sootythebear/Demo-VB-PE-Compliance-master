#!/bin/bash 

PEMASTER=$1
PECLIENT=$2
ADMINPWD=$3

echo "Creating a new Classification group, and assigning PE Agent and 'web' class to it.\n"

# Update the login details within JSON file
sed -e s/"PWD"/${ADMINPWD}/ < /tmp/scripts/templogin.json > /tmp/scripts/login.json

# Grab a TOKEN to access the classifier API
export TOKEN=`curl -k -X POST -H 'Content-Type: application/json' -d @/tmp/scripts/login.json https://${PEMASTER}:4433/rbac-api/v1/auth/token | cut -d'"' -f4`

# Grab the 'production' parent ID
PARENT=`curl -k https://${PEMASTER}:4433/classifier-api/v1/groups -H "X-Authentication:$TOKEN" | jq . | grep -B2 "Agent-specified" | grep "parent" | cut -d":" -f2 | cut -d'"' -f2`

# Create JSON file w/ detail
sed -e s/"PAR_ID"/${PARENT}/ -e s/"PEAGENT"/${PECLIENT}/ < /tmp/scripts/template.json > /tmp/scripts/group.json

# Update the Class list BEFORE creating new group
curl -k -X POST https://${PEMASTER}:4433/classifier-api/v1/update-classes -H "X-Authentication:$TOKEN"

# Create group via JSON file
curl -k -X POST -H 'Content-Type: application/json' https://${PEMASTER}:4433/classifier-api/v1/groups -H "X-Authentication:$TOKEN" -d @/tmp/scripts/group.json
