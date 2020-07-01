#!/bin/bash
#get number of hosts:
FILE="result.xml"
MYSQL_DB="nmap"
MYSQL_USER="root"
MYSQL_PASS=""
 
nrHosts=$(xmllint --xpath "count(//host)" $FILE)
echo "Number of Hosts: $nrHosts"


for ((hindex=1;hindex<$nrHosts;hindex++));
do
	#create insert statements for hosts
	hostname=$(xmllint --xpath "string(//host[$hindex]/hostnames/hostname/@name)" $FILE)
	state=$(xmllint --xpath "string(//host[$hindex]/status/@state)" $FILE)
	ip=$(xmllint --xpath "string(//host[$hindex]/address[@addrtype='ipv4']/@addr)" $FILE)
	mac=$(xmllint --xpath "string(//host[$hindex]/address[@addrtype='mac']/@addr)" $FILE)
	vendor=$(xmllint --xpath "string(//host[$hindex]/address[@addrtype='mac']/@vendor)" $FILE)


	echo "Insert Host: $hostname, $state, $ip, $mac, $vendor"

	mysql -u $MYSQL_USER -p $MYSQL_PASS $MYSQL_DB -e "insert into hosts(hostname,state,ip,mac,vendor) values ('$hostname','$state','$ip','$mac','$vendor');"
	hid=$(mysql -u $MYSQL_USER -p $MYSQL_PASS $MYSQL_DB -e "select id from hosts where ip='$ip';" -s -N)
	#
	nrPorts=$(xmllint --xpath "count(//host[$hindex]/ports/port)" $FILE)
	
	echo "Number of Ports: $nrPorts"
	for ((pindex=1;pindex<=$nrPorts;pindex++));
	do
		#create insert statements for ports
		
		portnumber=$(xmllint --xpath "string(//host[$hindex]/ports/port[$pindex]/@portid)" $FILE)
		protocol=$(xmllint --xpath "string(//host[$hindex]/ports/port[$pindex]/@protocol)" $FILE)
		state=$(xmllint --xpath "string(//host[$hindex]/ports/port[$pindex]/state/@state)" $FILE)
		service=$(xmllint --xpath "string(//host[$hindex]/ports/port[$pindex]/service/@name)" $FILE)

		echo "   Insert Port: $portnumber, $protocol, $state, $service"

		mysql -u $MYSQL_USER -p $MYSQL_PASS $MYSQL_DB -e "insert ignore into ports(portnumber,protocol,state,service) values($portnumber,'$protocol','$state','$service');"
		pid=$(mysql -u $MYSQL_USER -p $MYSQL_PASS $MYSQL_DB -e "select id from ports where portnumber=$portnumber and protocol='$protocol' and state='$state' and service='$service';" -s -N)

		mysql -u $MYSQL_USER -p $MYSQL_PASS $MYSQL_DB -e "insert into ports_hosts(hosts_id,ports_id) values ($hid,$pid)"
	done
done
