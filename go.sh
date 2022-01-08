#!/bin/sh

do_rb() {
	d=$1
	p=$d.rb
	if [ -f $p ] ; then
		echo "\n---------------------- day $d (ruby)"
		ruby $d.rb
	fi
}

do_cargo() {
	d=$1
	p=$d.cargo
	if [ -d $p ] ; then
		echo "\n---------------------- day $d (rust)"
		pushd $p
		cargo run --release
		popd
	fi
}

mkdir -p data
if [ -f .env ] ; then
	echo "Sourcing .env"
	. .env
	export SESSION
fi

mode="rb"
if [ "$1" == "--rust" ] ; then
	mode="cargo"
	shift
fi
echo "mode: $mode"

if [ -n "$1" ] ; then
	d=$(printf "%02d" $1)
	do_$mode $d
else
	for s in [012]*.$mode ; do
		echo "\n---------------------- day $(basename $s .$mode)"
		do_$mode $s
	done
fi
