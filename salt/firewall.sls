{% set firewall = pillar.get('firewall', {}) %}
{% set fw_zone = firewall.get('zone', 'public') %}

{% if grains['os_family'] == 'RedHat' %}

firewalld_service:
  service.running:
    - name: firewalld
    - enable: True

{% for port_group, ports in firewall.get('ports', {}).items() %}
{{ port_group }}_firewall:
  firewalld.present:
    - name: {{ fw_zone }}
    - ports:
      {% for port in ports %}
      - {{ port }}
      {% endfor %}
    - require:
      - service: firewalld_service
{% endfor %}

{% elif grains['os_family'] == 'Debian' %}

ufw_installed:
  pkg.installed:
    - name: ufw

ufw_service:
  service.running:
    - name: ufw
    - enable: True
    - require:
      - pkg: ufw_installed

ufw_enabled:
  cmd.run:
    - name: ufw --force enable
    - unless: '"ufw status | grep -q "Status: Active"'
    - require:
      - service: ufw_service

{% for port_group, ports in firewall.get('ports', {}).items() %}
{% for port in ports %}
{% set port_num, proto = port.split('/') %}
{{ port_group }}_{{ port_num }}_{{ proto }}_ufw:
  cmd.run:
    - name: ufw allow {{ port_num }}/{{ proto }}
    - unless: ufw status | grep -q "{{ port_num }}/{{ proto }}.*ALLOW"
    - require:
      - service: ufw_service
{% endfor %}
{% endfor %}

{% endif %}
