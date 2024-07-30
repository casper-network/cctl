#!/bin/bash

source $CCTL/activate
source $CCTL/cmds/infra/net/ctl_setup.sh
source $CCTL/cmds/infra/net/ctl_start.sh

tail -f $CCTL/assets/nodes/node-1/logs/node-stderr.log
