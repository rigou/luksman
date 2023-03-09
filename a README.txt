Project luksman 
2023-03-07

Main Repository : /mnt/node2/lv_dev/Projects/luksman/

Prerequisites : apt install cryptsetup-bin

Installation:
	chown root: luksman
	chmod 740 luksman
	cp luksman /usr/local/sbin
	# optionally, add this convenient alias :
	echo "alias lum='sudo /usr/local/sbin/luksman'" >>$HOME/.bashrc
