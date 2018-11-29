#!/bin/bash
usage() {
  echo "Usage: $0 [-s json_config]" 1>&2; 
  exit 1;
}

#Getting params
while getopts ":s:" o; do
  case "${o}" in
    s)
      s=${OPTARG}
        ;;
    *)
      usage
        ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${s}" ]; then
  usage
fi

#Reading values from json config
email=$(jq -r '.email' $s)
zones=$(jq -r '.zones' $s)
api_key=$(jq -r '.api_key' $s)
record=$(jq -r '.record' $s)

#Getting current record values and cleaning
curl --request GET "https://api.cloudflare.com/client/v4/zones/$zones/dns_records/$record" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $api_key" \
    -H "Content-Type: application/json" > temp.json

record_type=$(jq -r '.result.type' 'temp.json')
record_name=$(jq -r '.result.name' 'temp.json')
record_ip=$(jq -r '.result.content' 'temp.json')

rm temp.json

#Updating
if [ "$last_ip" != "$record_ip" ]; then
  public_ip=$(curl https://api.ipify.org)
  echo $public_ip > last_ip
  curl --request PUT "https://api.cloudflare.com/client/v4/zones/$zones/dns_records/$record" \
     -H "X-Auth-Email: $email" \
     -H "X-Auth-Key: $api_key" \
     -H "Content-Type: application/json" \
     --data '{"type":'\"$record_type\"',"name":'\"$record_name\"',"content":'\"$public_ip\"'}' > /dev/null
fi