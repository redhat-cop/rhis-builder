#!/bin/bash

# setup offline token
# OFFLINE_TOKEN=""
# export OFFLINE_TOKEN

# get access token
access_token=$(curl --silent \
              --request POST \
              --data grant_type=refresh_token \
              --data client_id=rhsm-api \
              --data refresh_token=$OFFLINE_TOKEN \
              https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token \
              | jq -r .access_token)

distributions=$(curl --silent \
                --request GET \
                --header "Authorization: Bearer $access_token" \
                --header "Content-Type: application/json" \
                https://console.redhat.com/api/image-builder/v1/distributions \
                | jq -r .[].name | sort)

#compose_id=$(curl --silent \
#                  --request POST \
#                  --header "Authorization: Bearer $access_token" \
#                  --header "Content-Type: application/json" \
#                  --data @request-base-image.json \
#                  https://console.redhat.com/api/image-builder/v1/compose
#                  | jq -r .id); echo $compose_id

#status=$(curl --silent \
#              --header "Authorization: Bearer $access_token" \
#              "https://console.redhat.com/api/image-builder/v1/composes/$compose_id" \
#              | jq .image_status.status)

#url=$(curl --silent      --header "Authorization: Bearer $access_token"      "https://console.redhat.com/api/image-builder/v1/composes/$compose_id" | jq -r .image_status.upload_status.options.url)

#image_name="image_$RANDOM.vmdk"

#curl --location --output $image_name $url

echo $distributions