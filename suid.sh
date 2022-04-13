#!/bin/bash
f_suid () {
local PATH
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
  if ! [ -f /root/suid.list ]; then
    echo "The list with SUID binaries can't be found."
  else
    while read -r suid; do
      file=$(command -v "$suid")
      if [ -x "$file" ]; then
          chmod -s "$file"
          oct=$(stat -c "%A" "$file" | sed 's/s/x/g')
          ug=$(stat -c "%U %G" "$file")
          dpkg-statoverride --remove "$file" 2> /dev/null
          dpkg-statoverride --add "$ug" "$oct" "$file" 2> /dev/null
      fi
    done <<< "$(grep -E '^[a-zA-Z0-9]' /root/suid.list)"
  fi
  while read -r suidshells; do
    if [ -x "$suidshells" ]; then
      chmod -s "$suidshells"
    fi
  done <<< "$(grep -v '^#' /etc/shells)"
}

f_suid
