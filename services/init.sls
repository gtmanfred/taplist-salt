restart nginx:
  service.running:
    - name: nginx
    - listen:
      - file: taplist config nginx

restart uwsgi:
  service.dead:
    - name: uwsgi@taplists.beer
    - listen:
      - file: taplist config uwsgi
    - onchanges:
      - file: taplist config uwsgi
