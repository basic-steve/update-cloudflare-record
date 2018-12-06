#!/bin/bash
usage() {
  echo "Usage: $0 [-s json_config]" 1>&2;
  exit 1;
}

get_json_from_cloudflare() {
  curl --request GET "https://api.cloudflare.com/client/v4/zones/$zones/dns_records/$record" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $api_key" \
    -H "Content-Type: application/json" > temp.json
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
email=$(jq -r '.cloudflare.email' $s)
zones=$(jq -r '.cloudflare.zones' $s)
api_key=$(jq -r '.cloudflare.api_key' $s)
record=$(jq -r '.cloudflare.record' $s)

last_ip=$(cat last_ip)

#Getting current record values and cleaning
get_json_from_cloudflare
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

  #Reading updated data from cloudflare
  get_json_from_cloudflare
  record_ip=$(jq -r '.result.content' 'temp.json')
  rm temp.json

  #Checking if record was updated successfully
  if [ "$public_ip" = "$record_ip" ]; then
    to=$(jq -r '.mail.to' $s)
    subject=$(jq -r '.mail.subject' $s)

    #Replacing mail template placeholders and sending
    sed -e "s/\${script_name}/$subject/" -e "s/\${last_ip}/$last_ip/" -e "s/\${current_ip}/$record_ip/" mail_template | ssmtp $to
  fi
fi