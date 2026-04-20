{% set apache = pillar.get('apache', {}) %}

include:
  - firewall

apache_install:
  pkg.installed:
    - name: {{ apache.get('package', 'httpd') }}

apache_service:
  service.running:
    - name: {{ apache.get('service', 'httpd') }}
    - enable: True
    - watch:
      - pkg: apache_install
      - file: apache_index

apache_index:
  file.managed:
    - name: {{ apache.get('index', {}).get('path', '/var/www/html/index.html') }}
    - source: {{ apache.get('index', {}).get('source', 'salt://index.html.jinja') }}
    - template: jinja
    - user: {{ apache.get('index', {}).get('user', 'root') }}
    - group: {{ apache.get('index', {}).get('group', 'root') }}
    - mode: {{ apache.get('index', {}).get('mode', '644') }}
    - defaults:
        minion_id: {{ grains['id'] }}
