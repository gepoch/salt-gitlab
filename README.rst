=============
 SALT GITLAB
=============

This is a salt state for deploying gitlab to centos backended by mysql.

Basically, for instant gratification:

1. From the master run::

  salt '*' state.highstate

2. Then run::

  salt '*' state.sls gitlab_deploy
   

This should be pretty easy to extend for postgres, or anything else.
