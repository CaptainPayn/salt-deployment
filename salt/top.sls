base:
  '*':
    - init
    - firewall
    - nfs
  'role:controller':
    - match: grain
    - slurm.controller
    - slurm.munge
  'role:worker':
    - match: grain
    - slurm.worker
    - slurm.munge
