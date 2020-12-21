[root@centos vagrant]# cat container.yaml
# playbook to test varaibles special hostvars. Ansible provides a way to define variable at the host level and they can be accessed as below.


#playbook

---
- hosts: localhost
  connection: local
  tasks:
     - name: loop debug inventory hostnames
       debug:
         msg: "the container host is {{ item }}"
       with_inventory_hostnames: container
     - name: loop debug items
       debug:
         msg: "the container host is {{ hostvars[item]['user'] }}"
       with_items: "{{ groups['container'] }}"

     - name: test hostvag itself
       debug: var=hostvars

 # Here is example of inventory file

#[container]
#container1 user=kiran
#container2 user=kiran2
#container3 user=kiran3
#container4 user=kiran4
