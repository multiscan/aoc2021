#!/bin/sh
mkdir -p data
if [ -f .env ] ; then
	echo "Sourcing .env"
	. .env
	export SESSION
fi
if [ -n "$1" ] ; then
	d=$(printf "%02d" $1)
	echo "\n---------------------- day $d"
	ruby $d.rb 
else
	for s in [012]*.rb ; do 
		echo "\n---------------------- day $(basename $s .rb)"
		ruby $s
	done
fi