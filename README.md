# How to use

DNS Server:

    you have to change two vars in ./bind9/bind9-playbook.yml
        1. DOMAIN: change it to domain name you have in mind. (ex. 'mywebsite.me')
        2. ARECORD: change it to ipv4 wich you wanna point your domain to it. (ex. '5.10.20.30')

    now run ansible-playbook with this yaml file:
        $ ansible-playbook bind9/bind9-playbook.yml
