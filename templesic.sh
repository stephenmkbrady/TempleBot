#!/bin/bash

if [ ! -f Bible.TXT ]; then
    echo "Downloading Bible.TXT..."
    wget http://www.templeos.org/Wb/Home/Wb2/Files/Text/Bible.TXT
    echo "Done."
fi

if [ "$(which sic)" == "" ]; then
    echo "sic not found. Please install it from http://tools.suckless.org/sic/, then try again."
    exit
fi

read -p "Server: " server
read -p "Nick: " nickname
read -p "Channel: " channel

infile="/tmp/in$server$nickname"
outfile="/tmp/out$server$nickname"
touch $infile
touch $outfile

tail -f $infile | sic -h "$server" -n "$nickname" >> $outfile &

echo "Please wait 10 seconds while we connect to the server."
sleep 10s
echo ":j $channel" >> $infile
echo "Channel joined."

tail -f -n 0 $outfile | \
    while read -r chan char date time nick cmd msg; do
	case $cmd in
	    !bible|!Bible)
		sleep 3s	# Be polite and give God time to think
		LINE=$(shuf -en 1 {1..100000} --random-source=/dev/urandom)
		echo "Line $LINE:" >> $infile
		tail -n $LINE Bible.TXT | head -n 16 >> $infile
		sleep 0.5s
		echo >> $infile
		;;
	    !god*|!God*)
		sleep 3s
		echo "$nick: $(shuf -n 10 /usr/share/dict/words --random-source=/dev/urandom | tr '\n' ' ')" >> $infile
		;;
	    !help|!Help)
		echo 'Oracle for IRC. Lets you talk with God. Available commands: !bible !God !help !source. This bot uses random numbers to pick lines and words from a few files. Be witty and charming, not earnest. God likes soap operas and hates arrogance.' >> $infile
		;;
	    !source|!Source)
		cat $0 | curl -F 'sprunge=<-' http://sprunge.us >> $infile
		;;
	esac
    done
