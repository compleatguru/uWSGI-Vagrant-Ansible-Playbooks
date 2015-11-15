description "uWSGI application server in Emperor mode"

start on runlevel [2345]
stop on runlevel [!2345]

setuid {{ deploy_user }}
setgid www-data

exec /usr/local/bin/uwsgi --emperor /etc/uwsgi/sites
