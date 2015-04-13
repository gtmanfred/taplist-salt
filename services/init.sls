restart nginx:
  module.run:
    - name: service.restart
    - m_name: nginx
    - listen:
      - file: taplist config nginx

restart uwsgi:
  module.run:
    - name: service.restart
    - m_name: uwsgi
    - listen:
      - file: taplist config uwsgi

restart redis:
  module.run:
    - name: service.restart
    - m_name: redis
    - listen:
      - file: redis30u
