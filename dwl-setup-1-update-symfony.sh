#! /bin/bash
# generate github access

OAUTH_TOKEN_EXISTS=[ -f /tmp/dwl_oauth_token ] && echo true || echo false
if [ "${OAUTH_TOKEN_EXISTS}" = true ]; then
    DWL_COMPOSER_TOKEN=$(cat /tmp/dwl_oauth_token);
    rm /tmp/dwl_oauth_token
fi

GITHUB_USER_ID=$(curl \
    --header "Authorization: token ${DWL_COMPOSER_TOKEN}" https://api.github.com/user \
    --silent | grep \"id\" | awk '{ print $2 }' | sed s/\"//g | sed s/,//g)

if [ ${GITHUB_USER_ID} = '' ]; then
    if [ ${DWL_COMPOSER_TOKEN} != '' ]; then
        # todo : sendmail to remove token if obsolete
    fi
    DWL_COMPOSER_TOKEN="";
fi

if [ ${DWL_COMPOSER_TOKEN} = '' ]; then
    DWL_COMPOSER_TOKEN=$(curl \
        --user ${GITHUB_USER_NAME}:${GITHUB_USER_PASSWD} \
        --request POST https://api.github.com/authorizations \
        --data "{ \"scopes\": [ \"repo\" ], \"note\": \"`hostname` - `whoami` - composer - auth.json - `date +"%Y-%m-%d %H%M"`\" }" \
         --write-out %{http_code} \
         --silent | grep \"token\" | awk '{ print $2 }' | sed s/\"//g | sed s/,//g)
fi

if [ ${DWL_COMPOSER_TOKEN} != '' ]; then
    echo ${DWL_COMPOSER_TOKEN} > /tmp/dwl_oauth_token
    composer config --global github-oauth.github.com ${DWL_COMPOSER_TOKEN}
fi

cd /var/www/html

composer update

HTTPDUSER=`ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1`
setfacl -R -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX app/cache app/logs web
setfacl -dR -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX app/cache app/logs web
