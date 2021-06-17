#!/bin/bash
# This is a simple bash script for the BBB Application Infrastructure deployment. 
# It basically glues together the parts running in loose coupeling during the deployment and helps to speed things up which
# otherwise would have to be noted down and put into the command line. 
# This can be migrated into real orchestration / automation toolsets if needed (e.g. Ansible, Puppet or Terraform)

# created by David Surey - suredavi@amazon.de
# Disclaimber: NOT FOR PRODUCTION USE - Only for demo and testing purposes

ERROR_COUNT=0; 

if [[ $# -lt 13 ]] ; then
    echo 'arguments missing, please provide at least email (-e), the aws profile string (-p), the domain name (-d), the deployment Stack Name (-s) and the hosted zone to be used (-h)'
    exit 1
fi

while getopts ":p:e:h:s:d:o:u:v:a:b:c:n:z:" opt; do
  case $opt in
    p) BBBPROFILE="$OPTARG"
	echo "p: ${OPTARG}"
    ;;
    e) OPERATOREMAIL="$OPTARG"
	echo "e: ${OPTARG}"
    ;;
    h) HOSTEDZONE="$OPTARG"
	echo "h: ${OPTARG}"
    ;;
    s) BBBSTACK="$OPTARG"
	echo "s: ${OPTARG}"
    ;;
    d) DOMAIN="$OPTARG"
	echo "d: ${OPTARG}"
    ;;
    o) ORGNAME="$OPTARG"
	echo "o: ${OPTARG}"
    ;;
    u) SUBDOMAIN="$OPTARG"
	echo "u: ${OPTARG}"
    ;;
    v) VPC="$OPTARG"
	echo "v: ${OPTARG}"
    ;;
    a) PRIVATEAPPLICATIONSUBNET="$OPTARG"
	echo "a: ${OPTARG}"
    ;;
    b) DATABASESUBNET="$OPTARG"
	echo "b: ${OPTARG}"
    ;;
    c) PUBLICAPPLICATIONSUBNET="$OPTARG"
	echo "c: ${OPTARG}"
    ;;
    n) DATABASEENGINE="$OPTARG"
	echo "n: ${OPTARG}"
    ;;
    z) GREENLIGHTIMAGE="$OPTARG"
	echo "z: ${OPTARG}"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: aws cli is not installed.' >&2
  exit 1
fi

echo "using AWS Profile $BBBPROFILE"
echo "##################################################"

echo "Validating AWS CloudFormation templates..."
echo "##################################################"
# Loop through the YAML templates in this repository
for TEMPLATE in $(find . -name 'bbb-on-aws-*.template.yaml'); do 

    # Validate the template with CloudFormation
    ERRORS=$(aws cloudformation validate-template --profile=$BBBPROFILE --template-body file://$TEMPLATE 2>&1 >/dev/null); 
    if [ "$?" -gt "0" ]; then 
        ((ERROR_COUNT++));
        echo "[fail] $TEMPLATE: $ERRORS";
    else 
        echo "[pass] $TEMPLATE";
    fi; 
    
done; 

# Error out if templates are not validate. 
echo "$ERROR_COUNT template validation error(s)"; 
if [ "$ERROR_COUNT" -gt 0 ]; 
    then exit 1; 
fi

echo "##################################################"
echo "Validating of AWS CloudFormation templates finished"
echo "##################################################"

# Deploy the Needed Buckets for the later build 
echo "deploy the Prerequisites of the BBB Environment and Application if needed"
echo "##################################################"
BBBPREPSTACK="${BBBSTACK}-Sources"
aws cloudformation deploy --stack-name $BBBPREPSTACK --profile=$BBBPROFILE --template ./templates/bbb-on-aws-buildbuckets.template.yaml
echo "##################################################"
echo "deployment done"

# get the s3 bucket name out of the deployment.
SOURCE=`aws cloudformation describe-stacks --profile=$BBBPROFILE --query "Stacks[0].Outputs[0].OutputValue" --stack-name $BBBPREPSTACK`

SOURCE=`echo "${SOURCE//\"}"`

# we will upload the needed CFN Templates to S3 containing the IaaC Code which deploys the actual infrastructure.
# This will error out if the source files are missing. 
echo "##################################################"
echo "Copy Files to the S3 Bucket for further usage"
echo "##################################################"
if [ -e . ]
then
    echo "##################################################"
    echo "copy BBB code source file"
    aws s3 sync --profile=$BBBPROFILE --exclude=".DS_Store" ./templates s3://$SOURCE
    aws s3 sync --profile=$BBBPROFILE --exclude=".DS_Store" ./scripts s3://$SOURCE
    echo "##################################################"
else
    echo "BBB code source file missing"
    echo "##################################################"
    exit 1
fi
echo "##################################################"
echo "File Copy finished"

# Setting the dynamic Parameters for the Deployment
PARAMETERS=" BBBOperatorEMail=$OPERATOREMAIL \
             BBBStackBucketStack=$BBBSTACK-Sources \
             BBBDomainName=$DOMAIN \
             BBBHostedZone=$HOSTEDZONE \
             BBBOrgName=$ORGNAME \
             BBBSubDomainName=$SUBDOMAIN \
             BBBVPCs=$VPC \
             BBBPrivateApplicationSubnets=$PRIVATEAPPLICATIONSUBNET \
             BBBPrivateDBSubnets=$DATABASESUBNET \
             BBBPublicApplicationSubnets=$PUBLICAPPLICATIONSUBNET \
             BBBDBEngineVersion=$DATABASEENGINE \
             BBBgreenlightImage=$GREENLIGHTIMAGE"

echo "#################PARAMETERS###########################"
echo $PARAMETERS
echo "##################################################"

# Deploy the BBB infrastructure. 
echo "Building the BBB Environment"
echo "#############Using Deploy#####################################"
aws cloudformation deploy --profile=$BBBPROFILE --stack-name $BBBSTACK \
   --capabilities CAPABILITY_NAMED_IAM \
   --parameter-overrides $PARAMETERS \
   $(jq -r '.Parameters | to_entries | map("\(.key)=\(.value)") | join(" ")' bbb-on-aws-param.json) \
   --template ./bbb-on-aws-master.template.yaml

echo "##################################################"
echo "Deployment finished"

exit 0 
