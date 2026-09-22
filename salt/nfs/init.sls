install_nfs_packages:
  pkg.installed:
    - name: {% if grains['os_family'] == 'Debian' %}nfs-common{% else %}nfs-utils{% endif %}

ensure_rpcbind_running:
  service.running:
    - name: rpcbind
    - enable: True
    - require:
      - pkg: install_nfs_packages
