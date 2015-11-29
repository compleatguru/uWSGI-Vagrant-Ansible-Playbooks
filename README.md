# uWSGI+Vagrant - Ansible Playbooks

This is a ansible package for wsgi applications that runs uWSGI and Nginx, based on Ubuntu 14.04. The playbook supports one or more applications (running uWSGI emperor mode). You can use this both locally using Vagrant or in production. It is currently HTTP only.

This package includes two playbooks, one called webserver that handles the general setup, while webapp registers a new webapp on the server.

#### webserver.yml
Performs basic server configurations, hardening and installs required packages

#### webapp.yml
Creates a boilerplate web applications, along with database and Nginx/uWSGI configuration.


## Included packages

- Nginx
- uWSGI (running in emperor mode)
- Postgres (with optional PostGIS extension)
- Redis

## Dependencies

- [First Five Minutes](https://github.com/fretscha-ansible/ansible-role-first-five-minutes)
- [pillow-prerequisites](https://github.com/korzeniewskipl/pillow-prerequisites)

Just run `ansible-galaxy install -r requirements.yml`

## Requirements

- Ansible
- Mac or Linux
- (Optionally) Vagrant


## Quick start

### Vagrant

Both playbooks will automatically run when you run `vagrant up`, it uses the inventory file generated by vagrant. Vagrant will forward the port 80 to 8080.

- Modify `ansible/vars/all.yml`
    - Change `app_name` and `app_domain` according to your wishes
- Update `Vagrantfile`
    - Change `synced_folder` so it matches your local path and appname
    - Example:

        ```
        /ansible/vars/all.yml

        app_name: music_app
        app_dmain: musicapp.com.dev

        /Vagrantfile

        config.vm.synced_folder "/local-repro/src", "/home/vagrant/music_app/web"
        config.vm.synced_folder "/local-repro", "/home/vagrant/music_app/app"

        ```

- Run `vagrant up`

To see the app you just added, you need to modify your `/etc/hosts` file:

```
Structure:
    ip-to-vagrant the-domain-used

Example:
    127.0.0.1 musicapp.com.dev
```

When you're done, just open the browser at: `http://musicapp.com.dev:8080`



### Linux

You need to first run webserver to setup the server, then run the webapp playbook to create your first application.

- Modify `ansible/vars/all.yml`
- Run `ansible-playbook ./ansible/webserver -K -u deployer -i provision`
- Run `ansible-playbook ./ansible/webapp -K -u deployer -i provision`


## Add another another webapp

### Vagrant

- Modify `ansible/vars/all.yml`
- Run `vagrant provision --provision-with webapp`

You can also pass along APP_NAME and APP_DOMAIN in this command.

- `APP_NAME=app2 APP_DOMAIN=app2.dev && vagrant provision --provision-with webapp`


### Linux

- Modify `ansible/vars/all.yml`
- Run `ansible-playbook ./ansible/webapp -K -u deployer -i provision`

You can also pass along app_name and app_domain in this command.

- `vagrant provision --provision-with webapp -e "app_name=app2 app_domain=app2.dev"`



## Package details
### Nginx
All applications are added in `sites-available` and `sites-enabled` uses proxy_pass and sockets to proxy wsgi.

- `service nginx reload`
- `service nginx start`
- `service nginx stop`

### uWSGI (running in emperor mode)
uWSGI are installed as a global python package and controlled through a upstart script called uwsgi.

#### Config

- *.sock files are stored in `/var/uwsgi/`
- Emperor vassals are stored in `/etc/uwsgi/sites/`

#### Commands

- `service uwsgi start`
- `service uwsgi stop`

### Postgres (with optional PostGIS extension)
All applications have their own database, named projectname_db. To enable the PostGis extension change pgsql.postgis to true in `ansible/vars/all.yml`



## Application structure

When you add a webapp the following files/directories will be created:

```
/home/user/project/
    web/                - This is the path uWSGI will serve
    app/                - (Vagrant only) The application folder where you ran vagrant, in case you need something outside the served dir.
    venv/               - Python virtualenv, used by uWSGI
    logs/               - Nginx log
    nginx_project       - Nginx config (symlinked to /etc/nginx/sites-available/)
    uwsgi_config.ini    - uWSGI config (symlinked to /etc/uwsgi/sites/)
    uwsgi_params        - uWSGI param config file
```

A python module called `wsgi.py` will be automatically created.


## Credits

Credits to [deploypython.com](http://www.deploypython.com/), [phansible.com](phansible.com) and sabmans [postgres gist](https://gist.github.com/sabman/ea3eea66f9de1e5d5f3c).


## Contributing

Want to contribute? Awesome. Just send a pull request.

## License

This playbook is released under the MIT License.
