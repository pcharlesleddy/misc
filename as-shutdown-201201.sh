#!/bin/sh -x

SUBNAME="20120321"
ZONE="us-east-1e"
SECURITY_GROUP="blarg-site"
REGION="us-east-1"
INSTANCE_SIZE="c1.medium"
LB_NAME="blarg-lb-as-"$SUBNAME
LC_NAME="blarg-lc-as-"$SUBNAME
LC_IMAGE_ID="ami-49975c20"
SG_NAME="blarg-as-gr-"$SUBNAME
MON_HIGH_NAME="asHighCPUAlarm_"$SUBNAME
MON_LOW_NAME="asLowCPUAlarm_"$SUBNAME

mon-delete-alarms $MON_LOW_NAME -f
mon-delete-alarms $MON_HIGH_NAME -f
as-delete-auto-scaling-group $SG_NAME -d -f
as-delete-launch-config $LC_NAME -f
elb-delete-lb $LB_NAME --force



