basic user home:
  module.run:
    - name: pkg.group_install
    - m_name: Development Tools
    - unless: rpm -q gcc

  pkg.installed:
    - name: python-virtualenv

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
