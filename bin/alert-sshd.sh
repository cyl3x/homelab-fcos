#!/bin/bash
# /etc/pam.d/sshd
# session optional pam_exec.so seteuid /../alert-sshd.sh

set -e -o pipefail
source /etc/alert_discord

if [ -z "$WEBHOOK" ] || [ "$PAM_TYPE" = 'close_session' ] || [[ "$IP_WHITELIST" == *" $PAM_RHOST "* ]]; then
    exit 0
fi

if [ "$SSH_CONNECTION" != "" ]; then
    PAM_RPORT="$(echo "${SSH_CONNECTION}" | awk '{ print $2 }' | tr -d '\n')"
fi

if [ "$SSH_AUTH_INFO_0" != "" ]; then
    PAM_RMETHOD="$(echo "${SSH_AUTH_INFO_0}" | tr -d '\n')"
fi

payload="$(cat << EOF
{
    "content": "@everyone SSH login **${PAM_USER}** from **${PAM_RHOST}**:${PAM_RPORT}",
    "embeds": [
        {
            "title": "[${PAM_SERVICE}] SSH Login: ${PAM_USER} from ${PAM_RHOST} on ${AL_HOST}",
            "color": 16734296,
            "fields": [
                {
                    "name": "User",
                    "value": "${PAM_USER}"
                },
                {
                    "name": "Local host",
                    "value": "${AL_HOST}"
                },
                {
                    "name": "Remote host",
                    "value": "$(hostname | tr -d '\n')"
                },
                {
                    "name": "Remote port",
                    "value": "${PAM_RPORT}"
                },
                {
                    "name": "Method",
                    "value": "${PAM_RMETHOD}"
                },
                {
                    "name": "Date",
                    "value": "$(date '+%d %b %Y at %H:%M:%S (%Z)' | tr -d '\n')"
                }
            ]
        }
    ]
}
EOF
)"

# Send the payload to the Discord webhook
curl -H "Content-Type: application/json" -X POST -d "$payload" "$WEBHOOK" &