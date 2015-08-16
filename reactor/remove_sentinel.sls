remove sentinel:
  runner.state.orchestrate:
    - mods: sentinels.reset
    - pillar:
        slave: {{data['redis_name']}}
        sentinel: {{data['sentinel_name']}}
