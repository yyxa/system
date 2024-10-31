SHELL := /bin/bash

include .env

.PHONY: up
up:
	@wakeonlan -i ${IP} -p ${PORT} ${MAC}

.PHONY: ssh
ssh:
	@ssh ${USER}@${IP}

.PHONY: down
down:
	@ssh ${USER}@${IP} "echo ${PASSWORD} | sudo -S shutdown -h now"

.PHONY: sleep
sleep:
	@ssh ${USER}@${IP} "echo ${PASSWORD} | sudo -S systemctl suspend"

.PHONY: reboot
reboot:
	@ssh ${USER}@${IP} "echo ${PASSWORD} | sudo -S reboot"

.PHONY: ping-port
ping-port:
	@nc -zv ${IP} ${PORT}

.PHONY: ping
ping:
	@ping ${IP}

.PHONY: vps
vps:
	@ssh ${VPS_USER}@${VPS_IP}