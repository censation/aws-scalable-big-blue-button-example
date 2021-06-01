#!/bin/bash
# This is a simple bash script for the BBB Application Infrastructure deployment. 
# It basically glues together the parts running in loose coupeling during the deployment and helps to speed things up which
# otherwise would have to be noted down and put into the command line. 
# This can be migrated into real orchestration / automation toolsets if needed (e.g. Ansible, Puppet or Terraform)

# created by David Surey - suredavi@amazon.de
# Disclaimber: NOT FOR PRODUCTION USE - Only for demo and testing purposes

ERROR_COUNT=0; 

if [[ $# -lt 5 ]] ; then
    echo 'arguments missing, please provide at least email (-e), the aws profile string (-p), the domain name (-d), the deployment Stack Name (-s) and the hosted zone to be used (-h)'
    exit 1
fi

while getopts ":p:e:h:s:d:" opt; do
  case $opt in
    p) BBBPROFILE="$OPTARG"
    ;;
    e) OPERATOREMAIL="$OPTARG"
    ;;
    h) HOSTEDZONE="$OPTARG"
    ;;
    s) BBBSTACK="$OPTARG"
    ;;
    d) DOMAIN="$OPTARG"
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
             BBBHostedZone=$HOSTEDZONE"

echo "#################PARAMETERS###########################"
echo $PARAMETERS
echo "##################################################"

# Deploy the BBB infrastructure. 
echo "Building the BBB Environment"
echo "#############Using Deploy#####################################"
#aws cloudformation deploy --profile=$BBBPROFILE --stack-name $BBBSTACK \
#    --capabilities CAPABILITY_NAMED_IAM \
#    --parameter-overrides $PARAMETERS \
#    $(jq -r '.Parameters | to_entries | map("\(.key)=\(.value)") | join(" ")' bbb-on-aws-param.json) \
#    --template ./bbb-on-aws-master.template.yaml


echo "#############Using create-stack#####################################"
aws cloudformation create-stack --profile=$BBBPROFILE --stack-name $BBBSTACK \
    --capabilities CAPABILITY_NAMED_IAM \
    --disable-rollback \
    --parameters ParameterKey=BBBOperatorEMail,ParameterValue=manjuraj.v@gmail.com ParameterKey=BBBStackBucketStack,ParameterValue=CENMeetStackSS2-Sources ParameterKey=BBBDomainName,ParameterValue=cenmeet.com ParameterKey=BBBHostedZone,ParameterValue=Z29BU1I287KH4O ParameterKey=BBBApplicationVersion,ParameterValue=xenial-22   ParameterKey=BBBApplicationInstanceOSVersion,ParameterValue=xenial-16.04  ParameterKey=BBBTurnInstanceOSVersion,ParameterValue=focal-20.04 ParameterKey=BBBECSInstanceType,ParameterValue=t3a.medium ParameterKey=BBBApplicationInstanceType,ParameterValue=t3a.medium ParameterKey=BBBApplicationDataVolumeSize,ParameterValue=50 ParameterKey=BBBApplicationRootVolumeSize,ParameterValue=20 ParameterKey=BBBTurnInstanceType,ParameterValue=t3a.micro ParameterKey=BBBDBInstanceType,ParameterValue=db.t3.medium ParameterKey=BBBServerlessAuroraMinCapacity,ParameterValue=2 ParameterKey=BBBServerlessAuroraMaxCapacity,ParameterValue=4 ParameterKey=BBBCACHEDBInstanceType,ParameterValue=cache.t3.micro ParameterKey=BBBVPCs,ParameterValue=10.1.0.0/16 ParameterKey=BBBPrivateApplicationSubnets,ParameterValue=10.1.5.0/24\\,10.1.6.0/24\\,10.1.7.0/24 ParameterKey=BBBPrivateDBSubnets,ParameterValue=10.1.9.0/24\\,10.1.10.0/24\\,10.1.11.0/24 ParameterKey=BBBPublicApplicationSubnets,ParameterValue=10.1.15.0/24\\,10.1.16.0/24\\,10.1.17.0/24 ParameterKey=BBBNumberOfAZs,ParameterValue=3 ParameterKey=BBBECSMaxInstances,ParameterValue=3 ParameterKey=BBBECSMinInstances,ParameterValue=1 ParameterKey=BBBECSDesiredInstances,ParameterValue=1 ParameterKey=BBBApplicationMaxInstances,ParameterValue=1 ParameterKey=BBBApplicationMinInstances,ParameterValue=1 ParameterKey=BBBApplicationDesiredInstances,ParameterValue=1 ParameterKey=BBBTurnMaxInstances,ParameterValue=1 ParameterKey=BBBTurnMinInstances,ParameterValue=1 ParameterKey=BBBTurnDesiredInstances,ParameterValue=1 ParameterKey=BBBDBName,ParameterValue=frontendapp ParameterKey=BBBDBEngineVersion,ParameterValue=12.4 ParameterKey=BBBEnvironmentStage,ParameterValue=dev ParameterKey=BBBEnvironmentName,ParameterValue=bbbonaws ParameterKey=BBBEnvironmentType,ParameterValue=single ParameterKey=BBBgreenlightImage,ParameterValue=bigbluebutton/greenlight:release-2.7.20 ParameterKey=BBBScaleliteApiImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-api ParameterKey=BBBScaleliteNginxImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-nginx ParameterKey=BBBScalelitePollerImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-poller ParameterKey=BBBScaleliteImporterImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-recording-importer ParameterKey=BBBCacheAZMode,ParameterValue=cross-az ParameterKey=BBBGreenlightMemory,ParameterValue=1024 ParameterKey=BBBGreenlightCPU,ParameterValue=512 ParameterKey=BBBScaleliteMemory,ParameterValue=2048 ParameterKey=BBBScaleliteCPU,ParameterValue=1024 \
    --template-body file://bbb-on-aws-master.template.yaml

echo "##################################################"
echo "Deployment finished"

exit 0 
