build server:
  runner.cloud.profile:
    - prof: centos-1-nova
    - instances:
      - {{data['server_name']}}
