#!/bin/bash
set -e

echo "Running entrypoint.sh..."
echo "Running as user:"
echo "$USER"
echo "Starting SSH ..."
ssh-keygen -A 
/usr/sbin/sshd 

su-exec pwpusher:pwpusher export RAILS_ENV=production

echo ""
if [ -z "$DATABASE_URL" ]
then
    echo "DATABASE_URL not specified. Assuming ephemeral backend. Database may be lost on container restart."
    echo "To set a database backend refer to https://docs.pwpush.com/docs/how-to-universal/#how-does-it-work"
    su-exec pwpusher:pwpusher export DATABASE_URL=sqlite3:db/db.sqlite3
else
    echo "According to DATABASE_URL database backend is set to $(echo $DATABASE_URL|cut -d ":" -f 1):..."
fi
echo ""

echo "Password Pusher: migrating database to latest..."
su-exec pwpusher:pwpusher bundle exec rake db:migrate

if [ -n "$PWP__THEME" ] || [ -n "$PWP_PRECOMPILE" ]; then
    echo "Password Pusher: precompiling assets for customizations..."
    su-exec pwppwpusher:pwpusherusher bundle exec rails assets:precompile
fi

echo "Password Pusher: starting puma webserver..."
exec su-exec pwpusher:pwpusher bundle exec puma -C config/puma.rb

exec "$@"