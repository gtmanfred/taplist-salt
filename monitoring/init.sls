monitoring repo:
  pkgrepo.managed:
    - name: rackspace
    - humanname: Rackspace Monitoring
    - gpgcheck: 1
    - gpgkey: https://monitoring.api.rackspacecloud.com/pki/agent/centos-7.asc
    - enabled: 1
    - baseurl: http://stable.packages.cloudmonitoring.rackspace.com/centos-7-x86_64

  pkg.installed:
    - name: rackspace-monitoring-agent
