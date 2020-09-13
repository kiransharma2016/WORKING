[root@centos ~]# cat pb5.yml
- hosts: localhost
  connection: local
  tasks:
  - name: Ansible register with_items example
    shell: "find *.txt"
    args:
      chdir: "/home/vagrant"
    register: with_output

  # Example group command from Ansible Playbooks
  - group:
      name: ansible
      state: present
    register: group_output

  - name: ensure a directory exists
    file:
       path: /home/ansible
       state: directory
    register: file_output

  - name: Create multiple directories
    file: path={{item}} state=directory
    with_items:
       - '/home/ansible/vn1'
       - '/home/ansible/vn2'
       - '/home/ansible/vn3'
    register: dir_output

  - name: Create User
    user: name=niranjan password=niranjan groups=ansible shell=/bin/bash
    register: user_output


  - local_action:
      module: lineinfile
      dest: "/home/ansible/ansible_log.txt"
      line: "i{{ item }}"
      create: yes
    with_items:
     - "{{ with_output}}"
     - "{{ group_output}}"
     - "{{ file_output}}"
     - "{{ dir_output}}"
     - "{{ user_output}}"

  - local_action:
      module: copy
      content: "{{ item }}"
      dest: /home/vagrant/file
    with_items:
     - "{{ with_output}}"
     - "{{ group_output}}"
     - "{{ file_output}}"
     - "{{ dir_output}}"
     - "{{ user_output}}"
