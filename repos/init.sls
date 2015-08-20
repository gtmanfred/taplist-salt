ius:
  pkgrepo.managed:
    - humanname: IUS Community Packages for Enterprise Linux 7 - $basearch
    - gpgcheck: 1
    - gpgkey: http://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY
    - enabled: 1
    - failovermethod: priority
    - names:
        - ius:
          - mirrorlist: "http://dmirr.iuscommunity.org/mirrorlist/?repo=ius-centos7&arch=$basearch"
        - ius-testing:
          - mirrorlist: "http://dmirr.iuscommunity.org/mirrorlist/?repo=ius-centos7-testing&arch=$basearch"

epel:
  pkgrepo.managed:
    - humanname: Extra Packages for Enterprise Linux 7 - $basearch
    - gpgcheck: 1
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    - enabled: 1
    - names:
        - epel:
            - baseurl: http://mirror.rackspace.com/epel/7/$basearch
        - epel-testing:
            - baseurl: http://mirror.rackspace.com/epel/testing/7/$basearch

clean repos:
  cmd.run:
    - name: yum clean all
