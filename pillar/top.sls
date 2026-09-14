base:
  'os_family:RedHat':
    - match: grain
    - webserver.redhat
  'os_family:Debian':
    - match: grain
    - webserver.debian
  '*':
    - firewall.common
  
