#!/usr/bin/env bash

RED_TEXT=`tput setaf 1`
GREEN_TEXT=`tput setaf 2`
ORANGE_TEXT=`tput setaf 5`
BLUE_TEXT=`tput setaf 6`
YELLOW_TEXT=`tput setaf 3`
RESET_TEXT=`tput sgr0`

#Unicode Icons
## https://apps.timwhitlock.info/emoji/tables/unicode
ICON_SUCCESS=`echo -e "\xE2\x9C\x94" `
ICON_FAIL=`echo -e "\xE2\x9D\x8C  FAILED " `
ICON_WARNING=`echo -e "\xE2\x9D\x97  WARNING " `
ICON_WAITING=`echo -e "\xE2\x9C\x8B" `
ICON_VERY_BAD_FAIL=`echo -e "\xF0\x9F\x92\x80" `
ICON_WAITING_USER_INPUT=`echo -e "\xF0\x9F\x91\x89  Waiting for User Input:  " `
ICON_TIMER=`echo -e "\xE2\x8F\xB0" `
ICON_COFFEE=`echo -e "\xF0\x9F\x8D\xB5" `
