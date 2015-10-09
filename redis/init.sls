{% set serviceip = salt['grains.get']('ip4_interfaces:eth2:0', '') %}
{% set masterip = salt['mine.get']('board1*', 'network.ip_addrs')['board1.taplists.beer'][0] %}
redis30u:
  pkg.installed:
    - pkgs:
      - redis30u
      - python-redis

  file.replace:
    - name: /etc/redis.conf
    - pattern: '^bind .*'
    - repl: {{"bind %s 127.0.0.1"|format(serviceip)}}

  service.running:
    - name: redis
    - enable: True

{%- for name, ip in salt['mine.get']('*', 'network.ip_addrs').iteritems() %}
{%- if salt['grains.get']('fqdn') != name %}
redis-sentinel-{{name}}:
  file.append:
    - name: /etc/redis-sentinel.conf
    - text: sentinel known-sentinel mymaster {{ip[0]}} 26379
    - unless: grep -q 'known-sentinel mymaster {{ip[0]}}' /etc/redis-sentinel.conf
{%- endif %}
{%- endfor %}

redis-sentinel:
  file.replace:
    - name: /etc/redis-sentinel.conf
    - pattern: "sentinel monitor mymaster 127.0.0.1 6379"
    - repl: {{"sentinel monitor mymaster %s 6379"|format(masterip)}}

  service.running:
    - name: redis-sentinel
    - enable: True

setup slaveof:
  redis.slaveof:
    - name: mymaster
    - host: localhost
    - onlyif: sleep 1
