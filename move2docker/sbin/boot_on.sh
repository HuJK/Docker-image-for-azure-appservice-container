#!/bin/bash
while :
do
  echo curl --connect-timeout 10 $REBOOT_BOOTON_URL
  curl --connect-timeout 10 $REBOOT_BOOTON_URL
done
