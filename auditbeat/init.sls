{% set auditbeat = pillar['auditbeat'] %}

add auditbeat repo:
  pkgrepo.managed:
    - humanname: Auditbeat Repo {{ auditbeat['repo'] }}
    - name: deb https://artifacts.elastic.co/packages/{{ auditbeat['repo'] }}/apt stable main
    - file: /etc/apt/sources.list.d/auditbeat.list
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch

install auditbeat:
  pkg.installed:
    - name: auditbeat
    - version: {{ auditbeat['version'] }}
    - hold: {{ auditbeat['hold'] | default(False) }}
    - require:
      - pkgrepo: add auditbeat repo

auditbeat:
  service.running:
    - restart: {{ auditbeat['restart'] | default(True) }}
    - enable: {{ auditbeat['enable'] | default(True) }}
    - require:
      - install auditbeat
    - watch:
      - pkg: auditbeat
      {% if salt['pillar.get']('auditbeat:config', {}) %}
      - file: /etc/auditbeat/auditbeat.yml
      {% endif %}

{% if salt['pillar.get']('auditbeat:config') %}
/etc/auditbeat/auditbeat.yml:
  file.serialize:
    - dataset_pillar: auditbeat:config
    - formatter: yaml
    - user: root
    - group: root
    - mode: 644
    - require:
      - install auditbeat
{% endif %}
