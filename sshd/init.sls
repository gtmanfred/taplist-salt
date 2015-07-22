sshd_config:
  augeas.change:
    - context: /files/etc/ssh/sshd_config
    - changes:
      - set PermitRootLogin without-password
