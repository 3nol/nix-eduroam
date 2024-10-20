set -eu

# If set, these variables confuse the flake-based binary below.
unset PYTHONHOME
unset PYTHONPATH

# Read arguments from environment variables.
INSTITUTION="${EDUROAM_INSTITUTION}"
USERNAME="${EDUROAM_USERNAME}"
PASSWORD_COMMAND="${EDUROAM_PASSWORD_COMMAND}"
FORCE_WPA=""
if [[ -n "${EDUROAM_FORCE_WPA:-}" && "${EDUROAM_FORCE_WPA:-}" != 0 ]]; then
  FORCE_WPA="--wpa_conf"
fi

# Download the per-institution installer and pass authentication.
curl --silent --data "device=linux" --get "$( \
  curl --silent --compressed --get 'https://discovery.eduroam.app/v1/discovery.json' | \
  jq -r '.instances[] | select(.name == "'"$INSTITUTION"'") | .profiles[0].eapconfig_endpoint' \
)" | \
python3 - --silent --username "$USERNAME" --password "$(eval "$PASSWORD_COMMAND")" $FORCE_WPA
