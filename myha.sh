#!/bin/bash
#Experiment with "secure" hashing
#Started: Thu Oct 8 10:59:53 PM 2015
#Written by Jonah Haney###

string=$1   #Set parameter 1 as string to be hashed

if [ -z "$2" ] #Check if parameter 2 (salt) is missing
then

while [ -z $saltseed ] || [ $saltseed -gt 65500000000 ] || [ $saltseed -lt 100000 ]
do
	saltseed=$(((RANDOM+RANDOM+RANDOM+RANDOM+RANDOM+RANDOM+RANDOM)*RANDOM*RANDOM*RANDOM*RANDOM/RANDOM/RANDOM))
	       #^^ If saltseed is too large or too small, re-initialize saltseed until within usable range ^^#
done

if [ $saltseed -lt 0 ]                 # If saltseed is negative
then                                   #
	saltseed=$((0-saltseed))       # Make saltseed positive
fi                                     #

saltval=$((10#$saltseed%65534+1))

saltstep=$((saltval))
saltdig1=0
saltdig2=0
saltdig3=0
saltdig4=0

while [ $saltstep -gt 4095 ]           #
do                                     #
	saltstep=$((saltstep-4096))    #
	saltdig1=$((saltdig1+1))       #
done                                   #


while [ $saltstep -gt 255 ]            #
do                                     #
	saltstep=$((saltstep-256))     #
	saltdig2=$((saltdig2+1))       #
done                                   #


while [ $saltstep -gt 15 ]             #
do                                     #
	saltstep=$((saltstep-16))      #
	saltdig3=$((saltdig3+1))       #
done                                   #

saltdig4=$saltstep

saltchar1=''
saltchar2=''
saltchar3=''
saltchar4=''

if [ $saltdig1 -gt 9 ]
then
	if [ $saltdig1 = 10 ]
	then
		saltchar1='a'
	fi
	if [ $saltdig1 = 11 ]
	then
		saltchar1='b'
	fi
	if [ $saltdig1 = 12 ]
	then
		saltchar1='c'
	fi
	if [ $saltdig1 = 13 ]
	then
		saltchar1='d'
	fi
	if [ $saltdig1 = 14 ]
	then
		saltchar1='e'
	fi
	if [ $saltdig1 = 15 ]
	then
		saltchar1='f'
	fi
else
	saltchar1=$saltdig1
fi

if [ $saltdig2 -gt 9 ]
then
	if [ $saltdig2 = 10 ]
	then
		saltchar2='a'
	fi
	if [ $saltdig2 = 11 ]
	then
		saltchar2='b'
	fi
	if [ $saltdig2 = 12 ]
	then
		saltchar2='c'
	fi
	if [ $saltdig2 = 13 ]
	then
		saltchar2='d'
	fi
	if [ $saltdig2 = 14 ]
	then
		saltchar2='e'
	fi
	if [ $saltdig2 = 15 ]
	then
		saltchar2='f'
	fi
else
	saltchar2=$saltdig2
fi

if [ $saltdig3 -gt 9 ]
then
	if [ $saltdig3 = 10 ]
	then
		saltchar3='a'
	fi
	if [ $saltdig3 = 11 ]
	then
		saltchar3='b'
	fi
	if [ $saltdig3 = 12 ]
	then
		saltchar3='c'
	fi
	if [ $saltdig3 = 13 ]
	then
		saltchar3='d'
	fi
	if [ $saltdig3 = 14 ]
	then
		saltchar3='e'
	fi
	if [ $saltdig3 = 15 ]
	then
		saltchar3='f'
	fi
else
	saltchar3=$saltdig3
fi

if [ $saltdig4 -gt 9 ]
then
	if [ $saltdig4 = 10 ]
	then
		saltchar4='a'
	fi
	if [ $saltdig4 = 11 ]
	then
		saltchar4='b'
	fi
	if [ $saltdig4 = 12 ]
	then
		saltchar4='c'
	fi
	if [ $saltdig4 = 13 ]
	then
		saltchar4='d'
	fi
	if [ $saltdig4 = 14 ]
	then
		saltchar4='e'
	fi
	if [ $saltdig4 = 15 ]
	then
		saltchar4='f'
	fi
else
	saltchar4=$saltdig4
fi

salt=$saltchar1$saltchar2$saltchar3$saltchar4

else                                   # If salt is given by parameters
	salt=$2                        # Set $salt equal to parameter 2
fi                                     #

hashorig=$salt$string
hashstr=$hashorig
hashval=0
ii=0
hashtmp=''
iimod=1
base=1

blockcipher () {
	block=$1                                                        # $block is HEX parameter
	i=0
	j=1
	
	while [ $i -lt ${#hashstr} ] || [ $i -lt 40 ]                   # Make loop run at least 40 iterations
	do

		if [ $ii -gt 39 -o $ii -lt 0 ]                          # After reaching end of $hashstr
		then                                                    #
			ii=$((base%40))                                 # Reset to selected position...
			if [ $((ii%2)) -eq 0 ]                          # 
			then                                            #
				iimod=1                                 #
			else                                            # ...and change's magnitude...
				iimod=2                                 # 
			fi                                              #
			if [ $((base%7)) -gt 2 ]                        #
			then                                            #
				iimod=$((0-iimod))                      # ...and direction
			fi                                              #
		fi                                                      # Yields a $hashstr of exactly 40 digits


		hashchar=${hashorig:$i:1}                               # $hashchar is "next" character of $hashorig

		if [ -z "$hashchar" ]                                   # If $hashchar is empty
		then                                                    #
			hashchar=0                                      # Set $hashchar to '0'
		fi                                                      # Yields empty $hashchar converted to usable byte

		hashdig=$(printf %d "'$hashchar")                       # $hashdig is ASCII value of $hashchar

		blockchar1=${block:0:1}                                 # $blockchar1 is the 1st digit of block
		blockchar2=${block:1:1}                                 # $blockchar2 is the 2nd digit of block
		blockchar3=${block:2:1}                                 # $blockchar3 is the 3rd digit of block
		blockchar4=${block:3:1}                                 # $blockchar4 is the 4th digit of block


		if [ $blockchar1 = a -o $blockchar1 = b -o $blockchar1 = c -o $blockchar1 = d -o $blockchar1 = e -o $blockchar1 = f ]
		then
			blockdig1=$(printf %d "'$blockchar1")
			blockdig1=$((blockdig1-87))
		else
			blockdig1=$blockchar1
		fi                                                      # $blockdig1 is the decimal value of hex: $blockchar1

		if [ $blockchar2 = a -o $blockchar2 = b -o $blockchar2 = c -o $blockchar2 = d -o $blockchar2 = e -o $blockchar2 = f ]
		then
			blockdig2=$(printf %d "'$blockchar2")
			blockdig2=$((blockdig2-87))
		else
			blockdig2=$blockchar2
		fi                                                      # $blockdig2 is the decimal value of hex: $blockchar2

		if [ $blockchar3 = a -o $blockchar3 = b -o $blockchar3 = c -o $blockchar3 = d -o $blockchar3 = e -o $blockchar3 = f ]
		then
			blockdig3=$(printf %d "'$blockchar3")
			blockdig3=$((blockdig3-87))
		else
			blockdig3=$blockchar3
		fi                                                      # $blockdig3 is the decimal value of hex: $blockchar3
			
		if [ $blockchar4 = a -o $blockchar4 = b -o $blockchar4 = c -o $blockchar4 = d -o $blockchar4 = e -o $blockchar4 = f ]
		then
			blockdig4=$(printf %d "'$blockchar4")
			blockdig4=$((blockdig4-87))
		else
			blockdig4=$blockchar4
		fi                                                      # $blockdig4 is the decimal value of hex: $blockchar4
	
		blockval=$(((10#$blockdig1*16*16*16+10#$blockdig2*16*16+10#$blockdig3*16+10#$blockdig4)*10#$base))
				#^^ $blockval is the decimal value of HEX: $block ^^#

		if [ $base -eq 0 ]
		then
			base=$hashdig
		fi

		##############################################################################################################
		##############################################################################################################
		####################----------          BEGIN CIPHER'S CRYPT ALGORITHM          ----------####################



		cipherfunc=$((base%7))

		if [ $cipherfunc -eq 0 ]
		then
			hashdig=$((10#$hashdig*10#$blockval))
			hashdig=$((10#$hashdig%(10#$base*10#$base)))
			hashdig=$((10#$hashdig+10#$blockdig1+10#$blockdig2+10#$blockdig3+10#$blockdig4))
			hashdig=$((10#$hashdig+(10#$hashdig%10#$base)))
		elif [ $cipherfunc -eq 1 ]
		then
			hashdig=$((10#$hashdig+10#$blockdig1+10#$blockdig3))
			hashdig=$((10#$hashdig%(10#$base*10#$base)))
			hashdig=$((10#$hashdig*10#$blockval))
			hashdig=$((10#$hashdig+(10#$hashdig%10#$base)))
		elif [ $cipherfunc -eq 2 ]
		then
			hashdig=$((10#$hashdig+(10#$hashdig%10#$base)))
			hashdig=$((10#$hashdig*10#$blockval))
			hashdig=$((10#$hashdig%(10#$base*10#$base)))
			hashdig=$((10#$hashdig+10#$blockdig2+10#$blockdig4))
		elif [ $cipherfunc -eq 3 ]
		then
			hashdig=$((10#$hashdig+(10#$hashdig%10#$base)))
			hashdig=$((10#$hashdig+10#$blockdig1+10#$blockdig4))
			hashdig=$((10#$hashdig%(10#$base*10#$base)))
			hashdig=$((10#$hashdig*10#$blockval))
		elif [ $cipherfunc -eq 4 ]
		then
			hashdig=$((10#$hashdig+10#$blockdig1+10#$blockdig2))
			hashdig=$((10#$hashdig%(10#$base*10#$base)))
			hashdig=$((10#$hashdig+(10#$hashdig%10#$base)))
			hashdig=$((10#$hashdig*10#$blockval))
		elif [ $cipherfunc -eq 5 ]
		then
			hashdig=$((10#$hashdig*10#$blockval))
			hashdig=$((10#$hashdig+(10#$hashdig%10#$base)))
			hashdig=$((10#$hashdig%(10#$base*10#$base)))
			hashdig=$((10#$hashdig+10#$blockdig3+10#$blockdig4))
		elif [ $cipherfunc -eq 6 ]
		then
			hashdig=$((10#$hashdig%(10#$base*10#$base)))
			hashdig=$((10#$hashdig+10#$blockdig1+10#$blockdig2+10#$blockdig4))
			hashdig=$((10#$hashdig+(10#$hashdig%10#$base)))
			hashdig=$((10#$hashdig*10#$blockval))
		fi



		####################----------           END CIPHER'S CRYPT ALGORITHM           ----------####################
		##############################################################################################################
		##############################################################################################################

		hashdig=$((hashdig-((10000000000-9876543210)*(hashdig/10000000000))))
		hashdig=$((hashdig%10000000000))
		hashdig=$((hashdig-(2*(hashdig/40000000))))
		hashdig=$((hashdig%40000000))
		hashdig=$((hashdig-(2*(hashdig/900000))))
		hashdig=$((hashdig%900000))

		base=$((10#$hashdig))                                   # Base is a variable number used in next blockcipher()

		hashdig=$((hashdig-(2*(hashdig/7000))))
		hashdig=$((hashdig%35))

		if [ $hashdig -lt 10 ]
		then
			hashchar=$hashdig
		elif [ $hashdig = 10 ]
		then
			hashchar=a
		elif [ $hashdig = 11 ]
		then
			hashchar=b
		elif [ $hashdig = 12 ]
		then
			hashchar=c
		elif [ $hashdig = 13 ]
		then
			hashchar=d
		elif [ $hashdig = 14 ]
		then
			hashchar=e
		elif [ $hashdig = 15 ]
		then
			hashchar=f
		elif [ $hashdig = 16 ]
		then
			hashchar=g
		elif [ $hashdig = 17 ]
		then
			hashchar=h
		elif [ $hashdig = 18 ]
		then
			hashchar=i
		elif [ $hashdig = 19 ]
		then
			hashchar=j
		elif [ $hashdig = 20 ]
		then
			hashchar=k
		elif [ $hashdig = 21 ]
		then
			hashchar=l
		elif [ $hashdig = 22 ]
		then
			hashchar=m
		elif [ $hashdig = 23 ]
		then
			hashchar=n
		elif [ $hashdig = 24 ]
		then
			hashchar=o
		elif [ $hashdig = 25 ]
		then
			hashchar=p
		elif [ $hashdig = 26 ]
		then
			hashchar=q
		elif [ $hashdig = 27 ]
		then
			hashchar=r
		elif [ $hashdig = 28 ]
		then
			hashchar=s
		elif [ $hashdig = 29 ]
		then
			hashchar=t
		elif [ $hashdig = 30 ]
		then
			hashchar=u
		elif [ $hashdig = 31 ]
		then
			hashchar=v
		elif [ $hashdig = 32 ]
		then
			hashchar='w'
		elif [ $hashdig = 33 ]
		then
			hashchar=x
		elif [ $hashdig = 34 ]
		then
			hashchar=y
		elif [ $hashdig = 35 ]
		then
			hashchar=z
		else
			echo 'critical error: $hashdig='$hashdig
			break
		fi
		
		hashtmp=${hashtmp:0:$ii}$hashchar${hashtmp:$((ii+1))}   # $hashtmp is temporary manipulative string to be stored as $hashstr

		i=$((i+1))
		j=$((j+1))
		ii=$((ii+iimod))
	done
	hashstr=$hashtmp
}

scramblecipher () {
	cipherval=$((16#$1*16#$2))
	hashval=$((36#$cipherval*36#$hashval*10#$base))
	hashstr=$(printf %x "'$hashval")
}

h0=165e    # 0001011001011110              #
h1=71d6    # 0111000111011001              #
h2=c320    # 1100001100100000              #
h3=00f9    # 0000000011111001              #
h4=ee79    # 1110111001111001              # Changing these will
h5=c6f9    # 1100011011111001              # completely alter
h6=ee25    # 1110111000100101              # the results of
h7=4faf    # 0100111110101111              # the algorithm
h8=f00f    # 1111000000001111              #
h9=bf78    # 1011111101111000              #


blockcipher $h0
scramblecipher $h0 $h9
blockcipher $h1
scramblecipher $h1 $h8
blockcipher $h2
scramblecipher $h2 $h7
blockcipher $h3
scramblecipher $h3 $h6
blockcipher $h4
scramblecipher $h4 $h5
blockcipher $h5
scramblecipher $h9 $h4
blockcipher $h6
scramblecipher $h8 $h3
blockcipher $h7
scramblecipher $h7 $h2
blockcipher $h8
scramblecipher $h6 $h1
blockcipher $h9
blockcipher $h5
blockcipher $h0

echo $hashstr':'$salt
