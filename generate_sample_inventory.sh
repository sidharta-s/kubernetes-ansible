#!/bin/bash

if (( $# != 1 ))
then
        echo "usage: $0 <host_list_file>"
        exit 1
fi

HOST_LIST_FILE=$1
HOST_ARRAY=(`cat ${HOST_LIST_FILE}`) 
HOST_COUNT=${#HOST_ARRAY[@]}


if (( $HOST_COUNT < 2 )) 
then
        echo "at least two hosts need to be specified in file: ${HOST_LIST_FILE}"
fi

MASTER=${HOST_ARRAY[0]}

echo "[masters]"
echo $MASTER
echo ""
echo "[etcd]"
echo $MASTER
echo ""
echo "[minions]"

for ((i=1; $i < $HOST_COUNT; i++))
do
  echo ${HOST_ARRAY[$i]} kube_ip_addr=10.244.${i}.1
done
