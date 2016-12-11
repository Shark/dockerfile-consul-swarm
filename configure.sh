#!/bin/bash
set -euo pipefail

digit_to_string() {
  declare digit="$1"
  case "$digit" in
    0) echo -n "zero" ;;
    1) echo -n "one" ;;
    2) echo -n "two" ;;
    3) echo -n "three" ;;
    4) echo -n "four" ;;
    5) echo -n "five" ;;
    6) echo -n "six" ;;
    7) echo -n "seven" ;;
    8) echo -n "eight" ;;
    9) echo -n "nine" ;;
  esac
}

number_to_string() {
  declare number="$1"
  local string=""
  local i

  for (( i=0; i<"${#number}"; i++ )); do
    local digit
    digit="${number:$i:1}"
    [[ $i -ne 0 ]] && string+="-"
    string+="$(digit_to_string "$digit")"
  done

  echo -n "$string"
}

main() {
  if [[ ! -f /consul/config/0_swarm.json ]]; then
    local ip
    local fourth
    ip="$(ip address show eth0 | grep 'inet ' | head -n1 | awk '{print $2}' | cut -d/ -f 1)"
    fourth="$(cut -d. -f 4 <<< "$ip")"
    local name
    name="$(number_to_string "$fourth")"
    cat > /consul/config/0_swarm.json <<EOF
{
  "node_name": "$name",
  "bind_addr": "$ip",
  "server": true,
  "bootstrap_expect": 3
}
EOF
  fi

  rm -f /consul/config/1_join.json

  local othersString
  local othersCount=0
  declare -a others

  while [[ $othersCount -lt 3 ]]; do
    sleep 1
    echo "Trying to find other consul servers..."
    othersString="$(dig tasks.consul +short)"
    readarray -t others <<< "$othersString"
    othersCount="${#others[@]}"
  done

  local json
  json="{\"retry_join\": ["
  local first=1
  for addr in "${others[@]}"; do
   if [[ $first -ne 1 ]]; then
     json+=","
   else
     first=0
   fi
   json+="\"$addr\""
  done
  json+="]}"

  echo "$json" > /consul/config/1_join.json

  exec docker-entrypoint.sh "$@"
}

main "$@"
