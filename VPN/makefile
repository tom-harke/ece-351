
define ABOUT
How to connect to pdx.edu via vpn:
   ssh tsh
   cd HERE
   sudo openvpn --config cecs.ovpn

How simulate
   ssh _@mo.ece.pdx.edu
   set -o vi

How to pull changes from pdx.edu to laptop
   git pull ece main 

How to verify
   firefox https://status.cecs.pdx.edu/

About
   firefox https://cat.pdx.edu/services/network/vpn-services/
endef

define git_config
[remote "ece"]
	url = _@mo.ece.pdx.edu:/u/_/ece-351
	fetch = +refs/heads/*:refs/remotes/origin/*
endef

export ABOUT
about:
	@echo "$$ABOUT"

