{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm.munge

slurm_controller_pkgs:
  pkg.installed:
    - pkgs: {{ slurm.pkgs | tojson }}

slurm_conf_controller:
  file.managed:
    - name: {{ slurm.confdir }}/slurm.conf
    - source: salt://slurm/files/slurm.conf.jinja
    - template: jinja
    - require:
      - pkg: slurm_controller_pkgs

slurm_group:
  group.present:
    - name: slurm
    - system: True

slurm_user:
  user.present:
    - name: slurm
    - system: True
    - gid: slurm
    - shell: /usr/sbin/nologin
    - home: /var/lib/slurm
    - createhome: False
    - require:
      - group: slurm_group

slurm_dirs:
  file.directory:
    - names:
      - /var/spool/slurmctld
      - /var/spool/slurmd
      - /var/spool/slurm
    - user: slurm
    - group: slurm
    - makedirs: True
    - require:
      - user: slurm_user
      - group: slurm_group
      - pkg: slurm_controller_pkgs

slurmctld_service:
  service.running:
    - name: {{ slurm.slurmctld_service }}
    - enable: True
    - require:
      - service: munge_service
      - file: slurm_conf_controller
    - watch:
      - file: slurm_conf_controller
