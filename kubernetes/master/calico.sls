{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}

/etc/calico/network-environment:
  file.managed:
    - source: salt://kubernetes/files/calico/network-environment.master
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja

/etc/calico/calicoctl.cfg:
  file.managed:
    - source: salt://kubernetes/files/calico/calicoctl.cfg.master
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja

/usr/bin/calicoctl:
  file.managed:
     - source: {{ master.network.get('source', 'https://github.com/projectcalico/calico-containers/releases/download/') }}{{ master.network.version }}/calicoctl
     - source_hash: md5={{ master.network.hash }}
     - mode: 751
     - user: root
     - group: root

{%- if master.network.get('systemd', true) %}

/etc/systemd/system/calico-node.service:
  file.managed:
    - source: salt://kubernetes/files/calico/calico-node.service.pool.master
    - user: root
    - group: root
    - template: jinja

calico_node:
  service.running:
    - name: calico-node
    - enable: True
    - watch:
      - file: /etc/systemd/system/calico-node.service

{%- endif %}

{%- endif %}
