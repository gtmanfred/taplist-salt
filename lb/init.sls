add to loadbalancer:
  grains.present:
    - name: loadbalancer
    - value: True

{%- if not grains.get('loadbalancer', False) %}
  event.send:
    - order: last
    - name: salt/{{salt['grains.get']('fqdn')}}/loadbalancer
    - data:
        hostname: {{salt['grains.get']('fqdn')}}
{%- endif %}
