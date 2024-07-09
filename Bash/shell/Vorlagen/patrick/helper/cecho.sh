#!/bin/bash

black='\e[30m'
red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
magenta='\e[35m'
cyan='\e[36m'
white='\e[37m'

cecho ()
{
  message=$1
  color=${2:-$black}

  echo -e -n "$color"
  echo "$message"
  echo -e -n "\e[0m"

  return
}