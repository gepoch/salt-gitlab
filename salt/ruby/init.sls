ruby-deps:
  pkg.installed:
    - names:
      - bash
      - coreutils
      - gzip
      - bzip2
      - gawk
      - sed
      - curl
      - subversion
      - autoconf
      - automake
      - bison
      - bzip2
      - curl
      - gcc-c++
      - gdbm-devel
      - libcurl-devel
      - libffi-devel
      - libicu-devel
      - libtool
      - libxml2-devel
      - libxslt-devel
      - libyaml-devel
      - logrotate
      - make
      - ncurses-devel
      - openssh-server
      - openssl-devel
      - patch
      - readline
      - readline-devel
      - zlib
      - zlib-devel

# Get it
ruby-{{pillar['versions']['ruby']}}:
  file.managed:
    - name: /root/ruby-{{pillar['versions']['ruby']}}.tar.gz
    - source: http://ftp.ruby-lang.org/pub/ruby/ruby-{{pillar['versions']['ruby']}}.tar.gz
    - source_hash: {{pillar['checksums']['ruby']}}

# Extract it
extract-ruby:
  cmd.wait:
    - cwd: /root
    - names:
      - tar xvf ruby-{{pillar['versions']['ruby']}}.tar.gz
    - watch:
      - file: ruby-{{pillar['versions']['ruby']}}
      

# Configure and install it.
configure-ruby:
  cmd.wait:
    - name: ./configure --prefix=/usr
    - cwd: /root/ruby-{{pillar['versions']['ruby']}}
    - require:
      - pkg: ruby-deps
    - watch:
      - cmd: extract-ruby

compile-ruby:
  cmd.wait:
    - name: make
    - cwd: /root/ruby-{{pillar['versions']['ruby']}}
    - require:
      - pkg: ruby-deps
    - watch:
      - cmd: configure-ruby

install-ruby:
  cmd.wait:
    - name: make install
    - cwd: /root/ruby-{{pillar['versions']['ruby']}}
    - require:
      - pkg: ruby-deps
    - watch:
      - cmd: compile-ruby
