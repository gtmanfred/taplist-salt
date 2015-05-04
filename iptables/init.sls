disable firewalld:
  service.dead:
    - name: firewalld
    - enable: False
  module.run:
    - name: service.mask
    - m_name: firewalld.service
    - onlyif: systemctl is-enabled firewalld.service

iptables rules first:
  iptables.insert:
    - position: 1
    - save: True
    - table: filter
    - chain: INPUT
    - match:
      - state
    - connstate: ESTABLISHED,RELATED
    - jump: ACCEPT

iptables rules loopback:
  iptables.insert:
    - position: 2
    - save: True
    - table: filter
    - chain: INPUT
    - in-interface: lo
    - jump: ACCEPT

iptables rules ssh:
  iptables.append:
    - save: True
    - table: filter
    - chain: INPUT
    - match:
      - state
      - tcp
    - proto: tcp
    - dport: 22
    - connstate: NEW
    - jump: ACCEPT

iptables rules http:
  iptables.append:
    - save: True
    - table: filter
    - chain: INPUT
    - match:
      - state
      - tcp
    - proto: tcp
    - dport: 80
    - connstate: NEW
    - jump: ACCEPT

iptables rules https:
  iptables.append:
    - save: True
    - table: filter
    - chain: INPUT
    - match:
      - state
      - tcp
    - proto: tcp
    - dport: 443
    - connstate: NEW
    - jump: ACCEPT

iptables rules redis:
  iptables.append:
    - save: True
    - table: filter
    - chain: INPUT
    - match:
      - state
      - tcp
    - proto: tcp
    - dport: 6379
    - source: 10.0.0.0/8
    - connstate: NEW
    - jump: ACCEPT

iptables rules redis sentinel:
  iptables.append:
    - save: True
    - table: filter
    - chain: INPUT
    - match:
      - state
      - tcp
    - proto: tcp
    - dport: 26379
    - source: 10.0.0.0/8
    - connstate: NEW
    - jump: ACCEPT

iptables rules last:
  iptables.append:
    - save: True
    - table: filter
    - chain: INPUT
    - jump: REJECT
