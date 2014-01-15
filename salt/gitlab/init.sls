build_rpms:
  pkg.installed:
    - names:
      - openssh-server
      - mysql-devel
      - redis
      - which
      - sudo

rsyslog:
  pkg:
    - installed
  service.running:
    - require:
      - pkg: rsyslog

redis:
  pkg:
    - installed
  service:
    - running

sshd:
  pkg.installed:
    - name: openssh-server
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://gitlab/conf/sshd.config
    - require:
      - pkg: sshd
      - service: rsyslog
  service.running:
    - watch:
      - file: sshd

nginx:
  pkg:
    - installed
  file.managed:
    - name: /etc/nginx/conf.d/gitlab.conf
    - source: salt://gitlab/conf/gitlab.nginx.conf
    - use:
      - file: gitlab_shell
    - require: 
      - pkg: nginx
      - user: gitlab
  user.present:
    - groups:
      - {{pillar['credentials']['group']}}
    - remove_groups: False
    - require:
      - pkg: nginx
      - user: gitlab
  service.running:
    - watch:
      - file: nginx
    - require:
      - file: /etc/nginx/conf.d/default.conf
      - file: nginx
      - user: nginx

/etc/nginx/conf.d/default.conf:
  file.absent:
    - require:
      - pkg: nginx

gitlab_config:
  file.managed:
    - name: {{pillar['credentials']['home']}}/gitlab/config/gitlab.yml
    - source: salt://gitlab/conf/gitlab.yml
    - context:
        username: {{pillar['credentials']['username']}}
        home: {{pillar['credentials']['home']}}
        fqdn: {{grains['id']}}
    - use:
      - file: gitlab_shell
    - require:
      - git: gitlab

gitlab_folders:
  file.directory:
    - makedirs: True
    - user: {{pillar['credentials']['username']}}
    - group: {{pillar['credentials']['username']}}
    - dir_mode: 770
    - names:
      {% for folder in [
          'gitlab',
          'gitlab/log',
          'gitlab/tmp',
          'gitlab-satellites',
          'gitlab/tmp/pids/',
          'gitlab/tmp/sockets/',
          'gitlab/public/uploads/',
      ]%}
      - {{pillar['credentials']['home']}}/{{folder}}
      {%endfor%}
    - require:
      - git: gitlab
      - user: gitlab

gitlab_home:
  file.directory:
    - makedirs: True
    - user: {{pillar['credentials']['username']}}
    - group: {{pillar['credentials']['username']}}
    - dir_mode: 750
    - names:
      - {{pillar['credentials']['home']}}/
    - require:
      - git: gitlab
      - user: gitlab

gitlab_sticky_folders:
  file.directory:
    - makedirs: True
    - user: {{pillar['credentials']['username']}}
    - group: {{pillar['credentials']['username']}}
    - dir_mode: 2770
    - names:
      {% for folder in [
        'repositories/',
      ]%}
      - {{pillar['credentials']['home']}}/{{folder}}
      {%endfor%}
    - require:
      - git: gitlab
      - user: gitlab

unicorn_config:
  file.managed:
    - name: {{pillar['credentials']['home']}}/gitlab/config/unicorn.rb
    - source: salt://gitlab/conf/unicorn.rb
    - use:
      - file: gitlab_shell
    - require:
      - git: gitlab

rack_attack_config:
  file.managed:
    - name: {{pillar['credentials']['home']}}/gitlab/config/initializers/rack_attack.rb
    - source: salt://gitlab/conf/rack_attack.rb
    - use:
      - file: gitlab_shell
    - require:
      - git: gitlab

database_config:
  file.managed:
    - name: {{pillar['credentials']['home']}}/gitlab/config/database.yml
    - source: salt://gitlab/conf/database.yml
    - context:
      username: {{pillar['database']['username']}}
      password: {{pillar['database']['password']}}
      database: {{pillar['database']['name']}}
    - use:
      - file: gitlab_shell
    - require:
      - git: gitlab

gitlab_default:
  file.managed:
    - name: /etc/default/gitlab
    - source: salt://gitlab/conf/gitlab.default.sh
    - template: jinja
    - context:
      username: {{pillar['credentials']['username']}}
      home: {{pillar['credentials']['home']}}
    - mode: 755

gitlab_init_link:
  file.symlink:
    - name: /etc/init.d/gitlab
    - target: {{pillar['credentials']['home']}}/gitlab/lib/support/init.d/gitlab
    - require:
      - git: gitlab

git_config:
  file.managed:
    - user: {{pillar['credentials']['username']}}
    - name: {{pillar['credentials']['home']}}/.gitconfig
    - source: salt://gitlab/conf/gitconfig
    - use:
      - file: gitlab_shell
    - require:
      - user: gitlab

bundler:
  cmd.run:
    - name: gem install bundler --no-ri --no-rdoc
    - unless: which bundler
    - require:
      - pkg: which

gitlab_bundle:
  cmd.run:
    - name: bundle install --deployment --without development test postgres aws 
    - cwd: {{pillar['credentials']['home']}}/gitlab
    - user: {{pillar['credentials']['username']}}
    - unless: bundle check
    - require:
      - git: gitlab
      - cmd: bundler
      - file: database_config
      - file: gitlab_config
      - file: gitlab_default
      - file: gitlab_folders
      - file: rack_attack_config
      - file: unicorn_config
      - pkg: build_rpms
      - pkg: sudo

gitlab_shell:
  git.latest:
    - name: https://gitlab.com/gitlab-org/gitlab-shell.git
    - user: {{pillar['credentials']['username']}}
    - target: {{pillar['credentials']['home']}}/gitlab-shell
    - rev: v{{pillar['versions']['gitlab-shell']}}
  file.managed:
    - name: {{pillar['credentials']['home']}}/gitlab-shell/config.yml
    - source: salt://gitlab/conf/config-gitlab-shell.yml
    - user: {{pillar['credentials']['username']}}
    - template: jinja
    - context:
        username: {{pillar['credentials']['username']}}
        home: {{pillar['credentials']['home']}}
        fqdn: {{grains['id']}}
    - require:
      - git: gitlab_shell
  cmd.run:
    - name: ./bin/install
    - cwd: {{pillar['credentials']['home']}}/gitlab-shell
    - user: {{pillar['credentials']['username']}}
    - unless: ls {{pillar['credentials']['home']}}/.ssh/
    - require:
      - git: gitlab_shell
      - file: gitlab_shell

gitlab:
  group.present:
    - name: {{pillar['credentials']['group']}}
  user.present:
    - name: {{pillar['credentials']['username']}}
    - home: {{pillar['credentials']['home']}}
    - password: {{pillar['credentials']['password']}}
    - groups:
      - {{pillar['credentials']['group']}}
    - createhome: True
    - remove_groups: False
    - fullname: GitLab
    - require:
      - group: gitlab
  git.latest:
    - name: https://gitlab.com/gitlab-org/gitlab-ce.git
    - user: {{pillar['credentials']['username']}}
    - target: {{pillar['credentials']['home']}}/gitlab
    - rev: v{{pillar['versions']['gitlab']}}
