atabase:
  pkg.installed:
    - names:
      - mysql-server
      - MySQL-python
  service.running:
    - name: mysqld
    - require:
      - pkg: database
    - watch:
      - pkg: database

database_setup:
  mysql_user.present:
    - name: {{pillar['database']['username']}}
    - password: {{pillar['database']['password']}}
    - require:
        - pkg: database
        - service: database

  mysql_database.present:
    - name: {{pillar['database']['name']}}
    - require:
      - pkg: database
      - service: database

  mysql_grants.present:
    - grant: all privileges
    - database: {{pillar['database']['name']}}.*
    - user: {{pillar['database']['username']}}
    - require:
        - mysql_user: database_setup
        - mysql_database: database_setup
        - pkg: database
        - service: database
