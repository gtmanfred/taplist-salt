add to loadbalancer:
{%- if not grains.get('loadbalancer', False) %}
  event.send:
    - name: salt/{{salt['grains.get']('fqdn')}}/loadbalancer
    - data:
        hostname: {{salt['grains.get']('fqdn')}}
{% endif %}
  grains.present:
    - name: loadbalancer
    - value: True

