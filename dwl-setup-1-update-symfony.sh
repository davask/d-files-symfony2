#! /bin/bash
# generate github access

DWL_OAUTH_TOKEN_EXISTS=$([ -f /tmp/dwl_oauth_token ] && echo true || echo false)
if [ "${DWL_OAUTH_TOKEN_EXISTS}" = true ]; then
    DWL_COMPOSER_TOKEN=$(cat /tmp/dwl_oauth_token)
    rm /tmp/dwl_oauth_token
fi

GITHUB_USER_ID=$(curl \
    --header "Authorization: token ${DWL_COMPOSER_TOKEN}" https://api.github.com/user \
    --silent | grep \"id\" | awk '{ print $2 }' | sed s/\"//g | sed s/,//g)

if [ "${GITHUB_USER_ID}" = '' ]; then
    if [ "${DWL_COMPOSER_TOKEN}" != '' ]; then
        # todo : sendmail to remove token if obsolete
        echo '';
    fi
    DWL_COMPOSER_TOKEN=""
fi

if [ "${DWL_COMPOSER_TOKEN}" = '' ]; then
    DWL_COMPOSER_TOKEN=$(curl \
        --user ${GITHUB_USER_NAME}:${GITHUB_USER_PASSWD} \
        --request POST https://api.github.com/authorizations \
        --data "{ \"scopes\": [ \"repo\" ], \"note\": \"`hostname` - `whoami` - composer - auth.json - `date +"%Y-%m-%d %H%M"`\" }" \
         --write-out %{http_code} \
         --silent | grep \"token\" | awk '{ print $2 }' | sed s/\"//g | sed s/,//g)
fi

if [ "${DWL_COMPOSER_TOKEN}" != '' ]; then
    echo ${DWL_COMPOSER_TOKEN} > /tmp/dwl_oauth_token
    composer config --global github-oauth.github.com ${DWL_COMPOSER_TOKEN}
fi

unset DWL_OAUTH_TOKEN_EXISTS
unset GITHUB_USER_ID
unset GITHUB_USER_NAME
unset GITHUB_USER_PASSWD
unset DWL_COMPOSER_TOKEN;

cd /var/www/html

composer update
