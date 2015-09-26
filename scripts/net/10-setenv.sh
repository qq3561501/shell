#! /bin/sh
#:set the envirenment that include essential tools 


path=`dirname $0`
. ${path}/reserve.script/env.shf
. ${path}/reserve.script/print_check.shf

returnarg=0
env_set
[ $? -ne 0 ] && returnarg=1
echo "return $returnarg" 




