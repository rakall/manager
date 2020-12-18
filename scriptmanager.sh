#!/bin/bash
#clish -c 'set hostname manager' -s
config_system -s 'hostname=chkmgmt&mgmt_admin_name=admin&mgmt_admin_passwd=Password1234&mgmt_gui_clients_radio=any&install_security_managment=true&install_security_gw=false&install_mgmt_primary=true&install_mgmt_secondary=false&timezone=Europe/Madrid'
mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" --domain 'System Data'
api restart