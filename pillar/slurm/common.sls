slurm:
  cluster_name: hpc_cluster
  controller: rocky-server
  munge_key_source: salt://slurm/files/munge.key
  slurmctld_port: 6817
  slurmd_port: 6818
