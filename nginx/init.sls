nginx:
  pkg.installed:
    - name: nginx

  service.running:
    - name: nginx
    - enable: True
    - listen:
      - file: nginx
      - file: nginx user
      - file: nginx default server
      - file: nginx localhost
      - file: taplist config nginx

  user.present:
    - name: nginx
    - groups:
      - taplist

  file.absent:
    - name: /etc/nginx/conf.d/default.conf

nginx user:
  file.replace:
    - name: /etc/nginx/nginx.conf
    - pattern: user +uwsgi;
    - repl: user nginx;

nginx default server:
  file.replace:
    - name: /etc/nginx/nginx.conf
    - pattern: "        listen       80 default_server;"
    - repl: "        listen       80;"

nginx localhost:
  file.replace:
    - name: /etc/nginx/nginx.conf
    - pattern: "        server_name  localhost;"
    - repl: ""

ssl certificate:
  file.managed:
    - name: /etc/pki/tls/certs/2016-taplists.beer.crt
    - user: root
    - group: root
    - mode: '0600'
    - contents_pillar: nginx:cert

ssl key:
  file.managed:
    - name: /etc/pki/tls/private/2016-taplists.beer.key
    - user: root
    - group: root
    - mode: '0600'
    - contents_pillar: nginx:key

taplist config nginx:
  file.managed:
    - name: /etc/nginx/conf.d/taplists.beer.conf
    - source: salt://nginx/files/taplists.beer.conf
