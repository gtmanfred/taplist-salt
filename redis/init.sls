{% set serviceip = salt['grains.get']('ip4_interfaces:eth2:0', '') %}
{% set masterip = salt['mine.get']('*', 'network.ip_addrs')['board1.taplists.beer'][0] %}
redis30u:
  pkg.installed:
    - name: redis30u

  file.replace:
    - name: /etc/redis.conf
    - pattern: '^bind .*'
    - repl: {{"bind %s 127.0.0.1"|format(serviceip)}}

  service.enabled:
    - name: redis

redis-sentinel:
  file.replace:
    - name: /etc/redis-sentinel.conf
    - pattern: "sentinel monitor mymaster 127.0.0.1 6379"
    - repl: {{"sentinel monitor mymaster %s 6379"|format(serviceip)}}

  service.enabled:
    - name: redis-sentinel

{%- for name, ip in salt['mine.get']('*', 'network.ip_addrs').iteritems() %}
{% if salt['grains.get']('fqdn') != name %}
#redis-slave-{{name}}:
#  file.append:
#    - name: /etc/redis-sentinel.conf
#    - text: sentinel known-slave mymaster {{ip[0]}} 6379
#    - unless: grep -q 'known-slave mymaster {{ip[0]}}' /etc/redis-sentinel.conf
#    - listen_in:
#      - service: restart redis-sentinel

redis-sentinel-{{name}}:
  file.append:
    - name: /etc/redis-sentinel.conf
    - text: sentinel known-sentinel mymaster {{ip[0]}} 26379
    - unless: grep -q 'known-sentinel mymaster {{ip[0]}}' /etc/redis-sentinel.conf
#    - listen_in:
#      - service: restart redis-sentinel
{%- endif %}
{%- endfor %}
