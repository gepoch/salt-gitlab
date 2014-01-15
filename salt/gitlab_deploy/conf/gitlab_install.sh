#!/usr/bin/env bash
cd {{home}}/gitlab
bundle exec rake gitlab:setup RAILS_ENV=production << EOF
yes
EOF
