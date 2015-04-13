uwsgi:
  file.managed:
    - names: 
      - /etc/tmpfiles.d/taplists.conf:
        - source: salt://uwsgi/files/tmpfiles.conf
      - /etc/systemd/system/uwsgi.service:
        - source: salt://uwsgi/files/uwsgi.service

  pkg.installed:
    - name: uwsgi-plugin-python

  cmd.run:
    - name: /usr/bin/systemd-tmpfiles --create /etc/tmpfiles.d/taplists.conf
    - unless: test -d /run/uwsgi/taplist

  user.present:
    - name: uwsgi
    - groups:
      - taplist

  service.running:
    - name: uwsgi
    - enable: True
    - listen:
      - file: taplist config uwsgi

taplist config uwsgi:
  file.managed:
    - name: /etc/uwsgi.d/taplists.beer.ini
    - source: salt://uwsgi/files/taplists.beer.ini
    - user: uwsgi
    - group: uwsgi
