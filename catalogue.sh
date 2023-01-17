- name: Configure NodeJS repos
  ansible.builtin.shell: curl -sL https://rpm.nodesource.com/setup_lts.x | bash

- name: Install NodeJS
  ansible.builtin.yum:
    name: nodejs
    state: installed

- name: Add Application User
  ansible.builtin.user:
    name: roboshop

- name: Remove old app content
  ansible.builtin.file:
    path: /app
    state: absent

- name: Create app Directory
  ansible.builtin.file:
    path: /app
    state: directory

- name: Download catalogue App content
  ansible.builtin.unarchive:
    src: https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
    dest: /app
    remote_src: yes

- name: Install Nodejs dependencies
  community.general.npm:
    path: /app
    state: latest

- name: COpy SystemD file
  ansible.builtin.copy:
    src: catalogue.service
    dest: /etc/systemd/system/catalogue.service

- name: Start Catalogue Service
  ansible.builtin.systemd:
    name: catalogue
    daemon_reload: yes
    enabled: yes
    state: restarted

- name: Copy MongoDB Yum Repo file
  ansible.builtin.copy:
    src: mongodb.repo
    dest: /etc/yum.repos.d/mongodb.repo

- name: Install MongoDB Server
  ansible.builtin.yum:
    name: mongodb-org-shell
    state: installed

- name: Load Schema
  community.mongodb.mongodb_shell:
    login_host: mongodb-dev.mobiqa.online
    file: "/app/schema/catalogue.js"
    idempotent: yes

