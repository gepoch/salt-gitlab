# Copy this lib/support/init.d/gitlab.default.example file to
# /etc/default/gitlab in order for it to apply to your system.

# RAILS_ENV defines the type of installation that is running.
# Normal values are "production", "test" and "development".
RAILS_ENV="production"

# app_user defines the user that GitLab is run as.
# The default is "git".
app_user="{{username}}"

# app_root defines the folder in which gitlab and it's components are installed.
# The default is "/home/$app_user/gitlab"
app_root="{{home}}/gitlab"

pid_path="$app_root/tmp/pids"
socket_path="$app_root/tmp/sockets"
web_server_pid_path="$pid_path/unicorn.pid"
sidekiq_pid_path="$pid_path/sidekiq.pid"
