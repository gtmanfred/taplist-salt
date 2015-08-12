basic user home:
  module.run:
    - name: pkg.group_install
    - m_name: Development Tools
    - unless: rpm -q gcc

  pkg.installed:
    - pkgs:
      - python-virtualenv
      - libyaml-devel

  user.present:
    - names:
      - taplist

  file.directory:
    - name: /home/taplist
    - mode: 0755
    - user: taplist
    - group: taplist

  git.latest:
    - name: git://github.com/bighops/taplist.git
    - target: /home/taplist/taplist
    - user: taplist

  virtualenv.managed:
    - name: /home/taplist/venv
    - user: taplist
    - python: /usr/bin/python2
    - requirements: /home/taplist/taplist/requirements.txt

taplist config file:
  file.managed:
    - name: /home/taplist/config.yml
    - source: salt://app/files/config.yml
    - user: taplist
    - group: taplist
    - mode: 0644

taplist stormpath config file:
  file.managed:
    - name: /home/taplist/.apiKey.properties
    - user: taplist
    - group: taplist
    - mode: 0600
    - contents: |
        apiKey.id = {{salt['pillar.get']('stormpath:apikey:id')}}
        apiKey.secret = {{salt['pillar.get']('stormpath:apikey:secret')}}
