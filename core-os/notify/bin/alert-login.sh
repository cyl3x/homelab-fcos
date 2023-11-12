#!/bin/bash
# add to /etc/pam.d/login, /etc/pam.d/sudo and /etc/pam.d/su
# session optional pam_exec.so seteuid /../alert-login.sh

# add to /etc/pam.d/su
# auth optional pam_exec.so seteuid /../alert-login.sh

set -e -o pipefail
source /etc/alert_discord

if [ -z "$WEBHOOK" ] || [ "$PAM_TYPE" == 'close_session' ] || [ "$PAM_USER" == 'core' ]; then
    exit 0
fi

type='Login'
pam_type='Open session'
color='16734296' # red

if [ "$PAM_USER" = "" ]; then # sudo auth request has empty user
    PAM_SERVICE="sudo?"
    type='Login attempt'
    pam_type='Authentication?'
    color='16734296' # yellow
elif [ "$PAM_TYPE" = "open_session" ]; then
    type='Successfull login'
elif [ "$PAM_TYPE" = "auth" ]; then
    type='Login attempt'
    pam_type='Authentication'
    color='16734296' # yellow
fi

payload="$(cat << EOF
{
    "content": "@everyone ${type} for **${PAM_USER}**",
    "embeds": [
        {
            "title": "[$PAM_SERVICE] ${type}: ${PAM_USER} on ${AL_DATE}",
            "color": $color,
            "fields": [{
                "name": "User",
                "value": "${PAM_USER}"
            }, {
                "name": "Local host",
                "value": "$(hostname | tr -d '\n')"
            }, {
                "name": "PAM type",
                "value": "${pam_type}"
            }, {
                "name": "Date",
                "value": "$(date '+%d %b %Y at %H:%M:%S (%Z)' | tr -d '\n')"
            }]
        }
    ]
}
EOF
)"

# Send the payload to the Discord webhook
curl -H "Content-Type: application/json" -X POST -d "$payload" "$WEBHOOK" &