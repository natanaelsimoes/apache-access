#!/bin/bash
# 
# MIT License
# 
# Copyright (c) 2017 Natanael Augusto Viana Simões
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

PROGNAME=${0##*/}
VERSION="1.0"
PROGPATH=$BASH_SOURCE

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() { # Exit with error observation
  printf "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  printf "\n"
  clean_up
  exit 1
}

graceful_exit() { # Exit without errors
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT"  INT

check_root() { # Check for root UID
  if [[ $(id -u) != 0 ]]; then
    error_exit "You must be the superuser to run this script."
  fi
}

check_root
read -p "Your username:" username
read -p "Web root folder[/var/www/html]:" wwwpath
if [[ $wwwpath == "" ]]; then
  wwwpath="/var/www/html"
fi
chgrp -R www-data "$wwwpath"
find "$wwwpath" -type d -exec chmod g+rx {} +
find "$wwwpath" -type f -exec chmod g+r {} +
chown -R "$username" "$wwwpath"/
find "$wwwpath" -type d -exec chmod u+rwx {} +
find "$wwwpath" -type f -exec chmod u+rw {} +
find "$wwwpath" -type d -exec chmod g+s {} +
chmod -R o-rwx "$wwwpath"/
graceful_exit
