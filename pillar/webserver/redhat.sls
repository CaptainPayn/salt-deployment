firewall:
  service: firewalld
  zone: public
  ports:
    salt_minion:
      - 4505/tcp
      - 4506/tcp
    apache_http:
      - 80/tcp
    apache_https:
      - 443/tcp

apache:
  package: httpd
  service: httpd
  docroot: /var/www/html
  index:
    path: /var/www/html/index.html
    source: salt://index.html.jinja
    user: root
    group: root
    mode: '644'
