#!/bin/bash

checkAutoindex ()
{
	local env=$AUTOINDEX
	if [ "$env" == "" ]
	then
		echo "Environment variable AUTOINDEX is unset. Please set it to on/off and then rerun this script."
	else
		if [ "$env" == "on" ]
		then
			export AUTOINDEX=on
			sed -i 's/autoindex off/autoindex on/' /etc/nginx/sites-enabled/nginx_site
			sed -i 's/index index_jballest.html index.htm index.php;/index index.htm index.php;/' /etc/nginx/sites-enabled/nginx_site
			service nginx restart
			echo "Autoindex is enabled..."
		elif [ "$env" == "off" ]
		then
			export AUTOINDEX=off
			sed -i 's/autoindex on/autoindex off/' /etc/nginx/sites-enabled/nginx_site
			sed -i 's/index index.htm index.php;/index index_jballest.html index.htm index.php;/' /etc/nginx/sites-enabled/nginx_site
			service nginx restart
			echo "Autoindex is disabled..."
		else
			echo "Environment variable AUTOINDEX is unset or it's different than on/off..."
		fi
	fi

}
	
case $1 in
	"on")
	export AUTOINDEX="on"
	checkAutoindex;
	;;
	"off")
	export AUTOINDEX="off"
	checkAutoindex;
	;;
	"env")
		checkAutoindex;
	;;
	"init")
		if [ "$AUTOINDEX" == "on" ] || [ "$AUTOINDEX" == "off" ]
		then
			echo "You set AUTOINDEX to $AUTOINDEX"
		else
			echo "Autoindex has not been defined... Turning off by default..."
			export AUTOINDEX=off
		fi
		checkAutoindex;
	;;
	*)
		echo "Error. You entered a wrong value. Values accepted are 'on' and 'off' (without hyphens)"
	;;
esac
