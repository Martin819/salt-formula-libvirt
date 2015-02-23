{% from "libvirt/map.jinja" import server with context %}

{%- if server.enabled %}

libvirt_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

libvirtd_config:
  file.managed:
  - name: {{ server.config }}
  - source: salt://libvirt/files/libvirtd.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: libvirt_packages

{%- if grains.os_family == 'RedHat' %}

libvirt_sysconfig:
  file.managed:
  - name: /etc/sysconfig/libvirtd
  - contents: 'LIBVIRTD_ARGS="--listen"'
  - require:
    - pkg: libvirt_packages

{%- endif %}

{%- if grains.os_family == 'Debian' %}

/etc/default/libvirt-bin:
  file.managed:
  - source: salt://libvirt/files/libvirt-bin
  - contents: 'LIBVIRTD_ARGS="--listen"'
  - require:
    - pkg: libvirt_packages

{%- endif %}

libvirt_service:
  service.running:
  - name: {{ server.service }}
  - enable: true
  - reload: true
  - watch:
    - file: libvirtd_config

{%- endif %}