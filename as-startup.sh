#!/bin/sh -x

TDAY=`date +%Y%m%d`
ZONES="us-east-1c,us-east-1d,us-east-1e"
SUBNAME="v02"
SECURITY_GROUP="blarg"
REGION="us-east-1"
INSTANCE_SIZE="c1.medium"
LB_NAME="blarg-lb-as-"$SUBNAME
LC_NAME="blarg-lc-as-"$SUBNAME
LC_IMAGE_ID="ami-af27f8c6"
SG_NAME="blarg-as-gr-"$SUBNAME
SU_POLICY_NAME="scaleUpPolicy_"$SUBNAME
SD_POLICY_NAME="scaleDownPolicy_"$SUBNAME
MON_HIGH_NAME="asHighCPUAlarm_"$SUBNAME
MON_LOW_NAME="asLowCPUAlarm_"$SUBNAME

echo $MON_LOW_NAME
#exit

elb-create-lb $LB_NAME --headers --listener "lb-port=8080,instance-port=8080,protocol=http" --availability-zones $ZONES --region $REGION

elb-configure-healthcheck $LB_NAME --headers --target "HTTP:8080/" --interval 60 --timeout 30 --unhealthy-threshold 3 --healthy-threshold 2 --region $REGION

as-create-launch-config $LC_NAME --image-id $LC_IMAGE_ID --instance-type $INSTANCE_SIZE --group $SECURITY_GROUP --region $REGION --monitoring-disabled

as-create-auto-scaling-group $SG_NAME --availability-zones $ZONES --launch-configuration $LC_NAME --min-size 2 --max-size 20 --load-balancers $LB_NAME --health-check-type ELB --grace-period 720 --region $REGION --tag "k=Name,v=as-webapp,p=true" --tag "k=role,v=webapp,p=true"

SCALE_UP_POLICY=`as-put-scaling-policy $SU_POLICY_NAME --auto-scaling-group $SG_NAME --adjustment=3 --type ChangeInCapacity --cooldown 300 --region $REGION`

mon-put-metric-alarm $MON_HIGH_NAME --region $REGION --comparison-operator GreaterThanThreshold --evaluation-periods 1 --metric-name CPUUtilization --namespace "AWS/EC2" --period 300 --statistic Average --threshold 80 --alarm-actions $SCALE_UP_POLICY --dimensions "AutoScalingGroupName=$SG_NAME"

SCALE_DOWN_POLICY=`as-put-scaling-policy $SD_POLICY_NAME --auto-scaling-group $SG_NAME --adjustment=-1 --type ChangeInCapacity --cooldown 600 --region $REGION`

mon-put-metric-alarm $MON_LOW_NAME --region $REGION --comparison-operator LessThanThreshold --evaluation-periods 1 --metric-name CPUUtilization --namespace "AWS/EC2" --period 300 --statistic Average --threshold 20 --alarm-actions $SCALE_DOWN_POLICY --dimensions "AutoScalingGroupName=$SG_NAME"

