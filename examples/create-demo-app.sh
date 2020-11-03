#!/bin/bash

# The following script will create a Java Spring Boot App repository configured against your dokku host.

# Usage:
# ./create-spring-app.sh <HOST>

set -euo pipefail

host=$1 # ip or hostname
app="demo.dokku.me"


echo -n "waiting for dokku and postgres plugin..."
until $(ssh -o LogLevel=QUIET -o ConnectTimeout=5 -o PasswordAuthentication=no -t "dokku@$host" postgres list > /dev/null); do
    printf '.'
    sleep 5
done

mkdir demo
cd demo

echo "initializing repo..."
curl https://start.spring.io/starter.zip -d dependencies=web,actuator,postgresql,data-jpa -d javaVersion=11 -o demo.zip
unzip demo.zip  
rm demo.zip

# Essential as Herokuish builds with Java 8 as default, the build will fail otherwise.
cat > system.properties <<-EOF
java.runtime.version=11
EOF

git init
git add --all

git commit -m "initial commit"

git remote add dokku dokku@"$host:$app"

function dokku { 
    ssh -o LogLevel=QUIET -o ConnectTimeout=5 -o PasswordAuthentication=no -t dokku@$host "$@" 
}
dokku apps:create "$app"
appNameShort=$(echo "$app" | cut -d '.' -f 1)
dokku postgres:create "$appNameShort"
dokku postgres:link "$appNameShort" "$app"
 
git push dokku master


echo "🎉 Your app is deployed! 🎁"
echo "You can test it with:"
echo "  curl --header \"Host: $app\" http://$host/actuator/health "