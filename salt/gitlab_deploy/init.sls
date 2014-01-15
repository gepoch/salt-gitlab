gitlab_install:
  file.managed:
    - name: {{pillar['credentials']['home']}}/gitlab_install.sh
    - source: salt://gitlab_deploy/conf/gitlab_install.sh
    - mode: 755
    - user: {{pillar['credentials']['username']}}
    - group: {{pillar['credentials']['group']}}
    - template: jinja
    - context:
      home: {{pillar['credentials']['home']}}
  cmd.run:
    - name: {{pillar['credentials']['home']}}/gitlab_install.sh
    - user: {{pillar['credentials']['username']}}
    - require:
      - file: gitlab_install

gitlab:
  service.running:
    - sig: unicorn_rails
    - require:
      - cmd: gitlab_install
    
      
