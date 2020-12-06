#!/usr/bin/env bash

if [[ $# != 2 ]] || [[ $1 != 'e' && $1 != 'd' ]]; then
	echo 'usage: ./code_convert.sh c|d passwd'
fi

src_dir='src'
tar_dir='tar'
out_dir='out'
passwd=$(md5 -qs ${2}jack)
passwd=$(md5 -qs $passwd)

function encode() {
	for item in $(ls $1); do
		if [ -d $1/$item ]; then
			mkdir -p $2/$item
			encode $1/$item $2/$item
		fi
		if [ -f $1/$item ] && [[ "${item##*.}"x != "db"x ]]; then
			tar -cJf - $1/$item | openssl des3 -nosalt -pbkdf2 -k $passwd -out $2/$item
		fi
	done
}

function decode() {
	for item in $(ls $1); do
		if [ -d $1/$item ]; then
			decode $1/$item $2/$item
		fi
		if [ -f $1/$item ]; then
			openssl des3 -d -k $passwd -nosalt -pbkdf2 -in $1/$item | tar xJf - -C ${out_dir}
		fi
	done
}

if [[ $1 == 'e' ]] && [ -d src ]; then
	rm -rf ${tar_dir}
	mkdir ${tar_dir}
	encode ${src_dir} ${tar_dir}
fi

if [[ $1 == 'd' ]] && [ -d tar ]; then
	rm -rf ${out_dir}
	mkdir ${out_dir}
	decode ${tar_dir} ${out_dir}
fi
