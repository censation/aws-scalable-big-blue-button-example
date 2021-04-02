
./setup.sh -p	default -e	manjuraj.v@gmail.com -h	Z29BU1I287KH4O -s	CENMeetStack5 -d	eventenergies.com

The below parameters in the script must be customized also. initiate aws cloud-formation delete-stack <stack-name> if deployment fails

 --parameters 
ParameterKey=BBBOperatorEMail,ParameterValue=manjuraj.v@gmail.com 
ParameterKey=BBBStackBucketStack,ParameterValue=CENMeetStack5-Sources
ParameterKey=BBBDomainName,ParameterValue=eventenergies.com
ParameterKey=BBBHostedZone,ParameterValue=Z29BU1I287KH4O


