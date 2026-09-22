base:
  '*':
    - firewall.common
    - slurm.common
    - slurm.nodes
  'os_family:RedHat':
    - match: grain
    - webserver.redhat
  'os_family:Debian':
    - match: grain
    - webserver.debian

  
