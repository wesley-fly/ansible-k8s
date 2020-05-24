#!/bin/sh
#
# how to use is: vi /etc/hosts , the content as below
# 10.110.25.226 test1
# 10.110.25.227 test2
# call the command line as below
# ./ssh-passless.sh test1 test2
#
#
ssh-keygen
for n in $*
do
  echo "=======passwd less $n ============"
  ssh-copy-id root@$n
done
