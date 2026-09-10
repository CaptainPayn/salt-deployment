base:
  'os_family:Redhat':
    - match: grain
    - webserver.redhat
  'os_family:Debian':
    - match: grain
    - webserver.debian
