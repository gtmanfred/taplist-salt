git:
  pkg.removed:
    - name: git

git2u:
  pkg.latest:
    - name: git2u

clone:
  git.latest:
    - name: git://github.com/saltstack/salt
    - target: /salt
    - onchanges_in:
      - cmd: remote add
      - cmd: remote update
      - cmd: cherrypick
      - cmd: install
      - service: restart

remote add:
  cmd.run:
    - name: git remote add cachedout git://github.com/cachedout/salt
    - cwd: /salt

remote update:
  cmd.run:
    - name: git remote update
    - cwd: /salt

cherrypick:
  cmd.run:
    - name: git cherry-pick ff8ee572dc580069b6513bc9e0f94cb3c8596354
    - cwd: /salt

install:
  cmd.run:
    - name: python setup.py install
    - cwd: /salt

restart:
  service.running:
    - name: salt-minion
    - listen: 
        - git: clone
