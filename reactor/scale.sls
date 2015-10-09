{%- if 'interface' in data['data'] %}
add to scaleup:
  runner.queue.insert:
    - queue: scaleup
    - items:
        - {{data['data']['id']}}
{%- else %}
add to scaledown:
  runner.queue.insert:
    - queue: scaledown
    - items:
        - {{data['data']['id']}}
{%- endif %}
