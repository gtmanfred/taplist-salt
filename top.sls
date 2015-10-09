base:
  '*':
    - sshd
    - psutil

  'salt*':
    - iptables.salt

  'board*.taplists.beer':
    - iptables
    - repos
    - redis
    - app
    - nginx
    - uwsgi
    - benchmark
    - lb
    - services
