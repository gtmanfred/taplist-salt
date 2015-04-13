{% set serviceip = salt['grains.get']('ip4_interfaces:eth1:0', '') %}
{% set masterip = salt['mine.get']('*', 'network.ip_addrs')['board1.taplists.beer'][0] %}
redis30u:
  pkg.installed:
    - name: redis30u

  file.replace:
    - name: /etc/redis.conf
    - pattern: '^bind .*'
    - repl: {{"bind %s 127.0.0.1"|format(serviceip)}}

  service.running:
    - name: redis
    - enable: True
    - listen:
      - file: redis30u
{%- if salt['grains.get']('fqdn') != 'board1.taplists.beer' %}
      - file: redis slaveof

redis slaveof:
  file.append:
    - name: /etc/redis.conf
    - text: {{ 'slaveof %s 6379'|format(masterip) }}
{% endif %}

redis-sentinel:
  file.replace:
    - name: /etc/redis-sentinel.conf
    - pattern: "sentinel monitor mymaster 127.0.0.1 6379 2"
    - repl: {{"sentinel monitor mymaster %s 6379 2"|format(masterip)}}

  service.running:
    - name: redis-sentinel
    - enable: True
    - listen:
      - file: redis-sentinel

#    - repl: {{"sentinel monitor mymaster %s 6379 2"|format(salt['mine.get']('*', 'network.ip_addrs')['board1.taplists.beer'][0])}}
