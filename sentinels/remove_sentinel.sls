remove sentinel:
  redis.reset_sentinel:
    - name: mymaster
    - slave: {{salt['pillar.get']('slave', None)}}
    - sentinel: {{salt['pillar.get']('sentinel', None)}}
    - sentinel_host: 127.0.0.1
    - sentinel_port: 26379
