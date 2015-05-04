restart nginx:
  module.run:
    - name: service.restart
    - m_name: nginx
    - listen:
      - file: taplist config nginx

restart uwsgi:
  service.dead:
    - name: uwsgi@taplists.beer
    - listen:
      - file: taplist config uwsgi
