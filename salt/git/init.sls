git_build_rpms:
  pkg.installed:
    - names:
      - gcc
      - libcurl-devel
      - expat-devel
      - gettext-devel
      - gettext-libs
      - zlib-devel
      - openssl-devel
      - perl-ExtUtils-MakeMaker

git:
  pkg:
    - removed

git_tar:
  file.managed:
    - name: /root/git-{{pillar['versions']['git']}}.tar.gz
    - source: https://git-core.googlecode.com/files/git-{{pillar['versions']['git']}}.tar.gz
    - source_hash: {{pillar['checksums']['git']}}

git_dir:
  cmd.wait:
    - cwd: /root/
    - name: tar -xzf git-{{pillar['versions']['git']}}.tar.gz
    - watch:
      - file: git_tar

git_install:
  cmd.wait:
    - cwd: /root/git-{{pillar['versions']['git']}}
    - name: make prefix=/usr all install
    - watch:
      - cmd: git_dir
      - pkg: git
    - require:
      - pkg: git_build_rpms
      - pkg: git
    