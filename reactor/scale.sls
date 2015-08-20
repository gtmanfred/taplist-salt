{%- if ['interface'] in data['data'] %}
scale up:
  runner.taplist.create:
    - name: 'board[0-9]+\.taplists\.beer'
    - num: 1
{%- else %}
scale down:
  runner.taplist.delete:
    - num: 3
{%- endif %}
