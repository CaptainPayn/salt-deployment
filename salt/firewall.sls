{% set firewall = pillar.get('firewall', {}) %}
{% set fw_service = firewall.get('service', 'firewalld') %}
{% set fw_zone = firewall.get('zone', 'public') %}

firewalld_service:
  service.running:
    - name: {{ fw_service }}
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
