
./setup.sh -p default -e manjuraj.v@gmail.com -h Z29BU1I287KH4O -s	CENMeetStack5 -d eventenergies.com

The below parameters in the script must be customized also. 

 --parameters 
ParameterKey=BBBOperatorEMail,ParameterValue=manjuraj.v@gmail.com 
ParameterKey=BBBStackBucketStack,ParameterValue=CENMeetStack5-Sources
ParameterKey=BBBDomainName,ParameterValue=eventenergies.com
ParameterKey=BBBHostedZone,ParameterValue=Z29BU1I287KH4O

Initiate the following command in case you want to delete the stack or deployment fails:
aws cloudformation delete-stack --stack-name <stack-name>
(Currently the ECS stack fails to delete and hence the complete stack doesn't get deleted)

The following paramteres are enough during deployment using create stack command : 

aws cloudformation create-stack --profile=default --stack-name CENMeet11 \
    --capabilities CAPABILITY_NAMED_IAM \
    --disable-rollback \
    --parameters ParameterKey=BBBOperatorEMail,ParameterValue=harithlk.is17@rvce.edu.in 
ParameterKey=BBBStackBucketStack,ParameterValue=CENMeet2-Sources 
ParameterKey=BBBOrgName,ParameterValue=RVCE
ParameterKey=BBBSubDomainName,ParameterValue=rv
ParameterKey=BBBDomainName,ParameterValue=cenmeet.com ParameterKey=BBBHostedZone,ParameterValue=Z097389247REZV7YJIXJ ParameterKey=BBBVPCs,ParameterValue=10.1.0.0/16 ParameterKey=BBBPrivateApplicationSubnets,ParameterValue=10.1.5.0/24\\,10.1.6.0/24\\,10.1.7.0/24 ParameterKey=BBBPrivateDBSubnets,ParameterValue=10.1.9.0/24\\,10.1.10.0/24\\,10.1.11.0/24 ParameterKey=BBBPublicApplicationSubnets,ParameterValue=10.1.15.0/24\\,10.1.16.0/24\\,10.1.17.0/24 ParameterKey=BBBDBEngineVersion,ParameterValue=12.4 ParameterKey=BBBgreenlightImage,ParameterValue=censation/greenlight-rvce:release-v2 
    --template-body /Users/harithlk/Desktop/Project/aws-scalable-big-blue-button-example/bbb-on-aws-master.template.yaml


The actual command with all the parameters passed : 

aws cloudformation create-stack --profile=$BBBPROFILE --stack-name $BBBSTACK \
    --capabilities CAPABILITY_NAMED_IAM \
    --disable-rollback \
    --parameters ParameterKey=BBBOperatorEMail,ParameterValue=harithlk.is17@rvce.edu.in  ParameterKey=BBBOrgName,ParameterValue=RVCE  ParameterKey=BBBSubDomainName,ParameterValue=rv  ParameterKey=BBBStackBucketStack,ParameterValue=CENMeet12-Sources ParameterKey=BBBDomainName,ParameterValue=cenmeet.com ParameterKey=BBBHostedZone,ParameterValue=Z097389247REZV7YJIXJ ParameterKey=BBBApplicationVersion,ParameterValue=xenial-22   ParameterKey=BBBApplicationInstanceOSVersion,ParameterValue=xenial-16.04  ParameterKey=BBBTurnInstanceOSVersion,ParameterValue=focal-20.04 ParameterKey=BBBECSInstanceType,ParameterValue=t3a.medium ParameterKey=BBBApplicationInstanceType,ParameterValue=t3a.medium ParameterKey=BBBApplicationDataVolumeSize,ParameterValue=50 ParameterKey=BBBApplicationRootVolumeSize,ParameterValue=20 ParameterKey=BBBTurnInstanceType,ParameterValue=t3a.micro ParameterKey=BBBDBInstanceType,ParameterValue=db.t3.medium ParameterKey=BBBServerlessAuroraMinCapacity,ParameterValue=2 ParameterKey=BBBServerlessAuroraMaxCapacity,ParameterValue=4 ParameterKey=BBBCACHEDBInstanceType,ParameterValue=cache.t3.micro ParameterKey=BBBVPCs,ParameterValue=10.1.0.0/16 ParameterKey=BBBPrivateApplicationSubnets,ParameterValue=10.1.5.0/24\\,10.1.6.0/24\\,10.1.7.0/24 ParameterKey=BBBPrivateDBSubnets,ParameterValue=10.1.9.0/24\\,10.1.10.0/24\\,10.1.11.0/24 ParameterKey=BBBPublicApplicationSubnets,ParameterValue=10.1.15.0/24\\,10.1.16.0/24\\,10.1.17.0/24 ParameterKey=BBBNumberOfAZs,ParameterValue=3 ParameterKey=BBBECSMaxInstances,ParameterValue=3 ParameterKey=BBBECSMinInstances,ParameterValue=1 ParameterKey=BBBECSDesiredInstances,ParameterValue=1 ParameterKey=BBBApplicationMaxInstances,ParameterValue=1 ParameterKey=BBBApplicationMinInstances,ParameterValue=1 ParameterKey=BBBApplicationDesiredInstances,ParameterValue=1 ParameterKey=BBBTurnMaxInstances,ParameterValue=1 ParameterKey=BBBTurnMinInstances,ParameterValue=1 ParameterKey=BBBTurnDesiredInstances,ParameterValue=1 ParameterKey=BBBDBName,ParameterValue=frontendapp ParameterKey=BBBDBEngineVersion,ParameterValue=12.4 ParameterKey=BBBEnvironmentStage,ParameterValue=dev ParameterKey=BBBEnvironmentName,ParameterValue=bbbonaws ParameterKey=BBBEnvironmentType,ParameterValue=scalable ParameterKey=BBBgreenlightImage,ParameterValue=censation/greenlight-rvce:release-v2 ParameterKey=BBBScaleliteApiImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-api ParameterKey=BBBScaleliteNginxImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-nginx ParameterKey=BBBScalelitePollerImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-poller ParameterKey=BBBScaleliteImporterImage,ParameterValue=blindsidenetwks/scalelite:v1.0.7-recording-importer ParameterKey=BBBCacheAZMode,ParameterValue=cross-az ParameterKey=BBBGreenlightMemory,ParameterValue=1024 ParameterKey=BBBGreenlightCPU,ParameterValue=512 ParameterKey=BBBScaleliteMemory,ParameterValue=2048 ParameterKey=BBBScaleliteCPU,ParameterValue=1024 \
    --template-body file://./bbb-on-aws-master.template.yaml