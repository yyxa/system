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

.PHONY: ls-proxy
ls-proxy:
	@env | grep -i proxy
	
.PHONY: rm-proxy
rm-proxy: 
	@unset all_proxy ALL_PROXY https_proxy HTTPS_PROXY http_proxy HTTP_PROXY ftp_proxy FTP_PROXY no_proxy NO_PROXY
