restart redis:
  service.running:
    - name: redis
    - listen:
      - file: redis30u

restart redis-sentinel:
  service.running:
    - name: redis-sentinel
    - listen:
      - file: redis-sentinel

restart nginx:
  service.running:
    - name: nginx
    - listen:
      - file: taplist config nginx

restart sshd:
  service.running:
    - name: sshd
    - listen:
      - augeas:sshd_config

restart uwsgi:
  service.dead:
    - name: uwsgi@taplists.beer
    - listen:
      - file: taplist config uwsgi
      - file: taplist config file
    - onchanges:
      - file: taplist config uwsgi
      - file: taplist config file
