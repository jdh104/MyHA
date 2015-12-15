#!/bin/bash
# This script used to test security of myha.sh by finding collisions

res=""
config=""
i=1
isdelim=0
torun=0

if [ -f collisions.mem ]
then
	if [ ! -z "`cat collisions.mem`" ]
	then
		read -p "Would you like to continue the last test ran? (Y/n) " res
		if [ $res = 'Y' -o $res = 'y' ]
		then
			config=`cat collisions.mem`
			length=${#config}
			isdelim=0
			while [ $isdelim = 0 ]
			do
				char=${config:$i:6}
				i=$((i+1))
				if [ "$char" = "&salt=" ]
				then
					isdelim=1
				fi
			done
			teststring=${config:0:$((i-1))}
			j=$i
			isdelim=0
			while [ $isdelim = 0 ]
			do
				char=${config:$j:5}
				j=$((j+1))
				if [ "$char" = "&val=" ]
				then
					isdelim=1
				fi
			done
			testsalt=${config:$((i+5)):$((j-i-6))}
			stringval=${config:$((j+4)):$((length-j-4))}
		else
			teststring="$1"
			testsalt="$2"
			stringval="$3"
		fi
	else
		teststring="$1"
		testsalt="$2"
		stringval="$3"
	fi
else
	echo '' > collisions.mem
fi

collided=0

if [ -z "$teststring" ]
then
	teststring="password"
fi

if [ -z "$testsalt" ]
then
	testsalt=0001
fi

if [ -z "$stringval" ]
then
	stringval=0
fi

if [ -f collisions.log ]
then
	donothing=0
else
	echo ' Collisions recorded by collisionfinder.sh (Written by Jonah Haney)' > collisions.log
	echo '--------------------------------------------------------------------' >> collisions.log
fi

if [ -z "$testsalt" ]
then
	testsalt=$((RANDOM))"100"
	testsalt=${testsalt:0:4}
fi

if [ -z "$teststring" ]
then
	teststring=$RANDOM
fi

testhash=`./myha.sh "$teststring" "$testsalt"`

while [ "$torun" -lt 1 ] || [ "$torun" -gt 10 ]
do
	read -p "How many threads to run? (MAX: 10) " torun
done

while [ 1 -eq 1 ]  #indefinitely
do
	collided=0
	while [ $collided -eq 0 ]
	do
		echo "$teststring&salt=$testsalt&val=$stringval" > collisions.mem
		k=0
		while [ $k -lt $torun ]
		do
		{
			stringval=$((stringval+k))
			subjecthash=`./myha.sh "$stringval" "$testsalt"`
			if [ $subjecthash = $testhash ]
			then
				printf "100% MATCH"
				collided=1
			else
				i=0
				j=0
				while [ $i -lt 40 ]
				do
					if [ ${subjecthash:i:1} = ${testhash:i:1} ]
					then
						j=$((j+250))
					fi
					i=$((i+1))
				done
				percentmatch=$((j/100))
				if [ $percentmatch -ge 10 ]
				then
					printf "testing $teststring for collision with $stringval using salt ($testsalt) "
					printf " $percentmatch%% MATCH"    # %% is needed to print a literal '%'
					if [ $percentmatch -ge 25 ]
					then
						echo " $percentmatch% MATCH RECORDED ON "`date` >> collisions.log
						printf " BETWEEN $teststring AND $stringval" >> collisions.log
						echo "with salt: "$testsalt" YIELDED HASHES:" >> collisions.log
						echo " "$testhash >> collisions.log
						echo " "$subjecthash >> collisions.log
						echo "" >> collisions.log
					fi
				else
					printf "testing $teststring for collision with $stringval using salt ($testsalt) "
					printf "  $percentmatch%% MATCH"   # %% is needed to print a literal '%'
				fi
			echo ""
			fi
		} &
		sleep .1
		k=$((k+1))
		done
		stringval=$((stringval+$torun))
		wait
	done
	echo '  COLLISION!'
	echo 'BETWEEN '"$teststring"' AND '$stringval
	echo 'YIELDED HASH: '$testhash
	echo 'COLLISION RECORDED ON '`date` >> collisions.log
	echo 'BETWEEN '"$teststring"' AND '"$stringval"' with salt: '$testsalt >> collisions.log
	echo 'YIELDED HASH: '$testhash >> collisions.log
	echo "" >> collisions.log
	collided=0
done
