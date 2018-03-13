#!/bin/bash

# This script is required to review the Puppet Agent exit code.
# Per Puppet documentation, exit code of 2 equals successful changes,
# 4 equals failures, and 6 equals both success and failures.
#
# Terraform only works with an 0 exit code, so this script will review the
# the results, and provide an exit code of 0 for a Puppet Agent exit code
# of 2.

/opt/puppetlabs/bin/puppet agent -t
RESULT=`echo $?`

if test $RESULT -eq 0 -o $RESULT -eq 2
then
	EXITCODE=0
else
	EXITCODE=2
fi

exit $EXITCODE
