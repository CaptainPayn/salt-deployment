{% from "slurm/map.jinja" import slurm with context %}

munge_pkg:
  pkg.installed:
    - name: munge

munge_key:
  file.managed:
    - name: /etc/munge/munge.key
    - source: {{ pillar['slurm']['munge_key_source'] }}
    - user: munge
    - group: munge
    - mode: '0400'
    - require:
      - pkg: munge_pkg

munge_service:
  service.running:
    - name: {{ slurm.munge_service }}
    - enable: True
    - watch:
      - file: munge_key
