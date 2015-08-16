reset sentinels:
  salt.state:
    - tgt: 'board[1-8].*'
    - tgt_type: pcre
    - batch: 1
    - sls:
      - sentinels.remove_sentinel
    - pillar:
        slave: {{pillar.get('slave', None)}}
        sentinel: {{pillar.get('sentinel', None)}}
