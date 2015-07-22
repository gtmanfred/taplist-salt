restart nginx:
  service.running:
    - name: nginx
    - listen:
      - file: taplist config nginx

restart sshd:
  service.running:
    - name: ssdh
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
