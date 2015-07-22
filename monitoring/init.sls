{%- set apikey = salt['pillar.get']('cloud:providers:my-nova:api_key') %}
{%- set username = salt['pillar.get']('cloud:providers:my-nova:user') %}
rackspace-monitoring-agent:
  pkgrepo.managed:
    - name: rackspace
    - humanname: Rackspace Monitoring
    - gpgcheck: 1
    - gpgkey: https://monitoring.api.rackspacecloud.com/pki/agent/centos-7.asc
    - enabled: 1
    - baseurl: http://stable.packages.cloudmonitoring.rackspace.com/centos-7-x86_64

  pkg.installed:
    - name: rackspace-monitoring-agent

  cmd.run:
    - name: rackspace-monitoring-agent --setup --username {{username}} --apikey {{apikey}}
    - unless: grep -q monitoring_token /etc/rackspace-monitoring-agent.cfg

  service.running:
    - name: rackspace-monitoring-agent
