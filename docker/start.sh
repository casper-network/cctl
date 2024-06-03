#!/bin/bash

source $CCTL/activate
source $CCTL/cmds/infra/net/setup.sh
source $CCTL/cmds/infra/net/start.sh

tail -f $CCTL/assets/nodes/node-1/logs/node-stderr.log
