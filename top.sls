base:
  '*':
    - sshd

  'salt*':
    - iptables.salt

  'board*.taplists.beer':
    - iptables
    - repos
    - redis
    - app
    - nginx
    - uwsgi
    - services
