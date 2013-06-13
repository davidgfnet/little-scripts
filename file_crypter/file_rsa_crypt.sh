
# File RSA encrypting
# 
# Takes an input file and encrypts/decrypts it using RSA+AES crypto.
# Basically it generates a random AES key and uses it to crypt the 
# the input file. Then it crypts the AES key using public key crypto
# and stores both, the crypted key and the message in a single file
# For decrypting it does the inverse process
# Everything is stored in base64 for better ASCII transmission

# Usage:
if [ $# -ne 3 ]; then
	echo "Usage: $0 inputfile rsakey enc|dec"
	exit
fi

# Encrypt
if [ $3 == "enc" ]; then
	# Generate the AES key
	aeskey=`dd if=/dev/urandom of=/dev/stdout bs=512 count=16 2> /dev/null| sha256sum | cut -d " " -f1`
	dd if=/dev/urandom of=/dev/null bs=512 count=32 2> /dev/null
	iv=`dd if=/dev/urandom of=/dev/stdout bs=512 count=16 2> /dev/null| sha256sum | cut -d " " -f1| cut -c 48-` 

	# Crypt key and iv with the RSA key
	aeskey2=`echo -n "$aeskey" | openssl rsautl -encrypt -pubin -inkey "$2" -in /dev/stdin -out /dev/stdout |base64 -w 0`
	iv2=`echo -n "$iv" | openssl rsautl -encrypt -pubin -inkey "$2" -in /dev/stdin -out /dev/stdout | base64 -w 0`

	echo $aeskey2
	echo $iv2
	
	# Crpyting
	openssl enc -e -aes-256-cbc -in "$1" -out /dev/stdout -K "$aeskey" -iv "$iv" | base64 -w 0
fi

# Decrypt
if [ $3 == "dec" ]; then
	# Read key and iv
	aeskey=`cat "$1" | head -1 | tr -d '\b'`
	iv=`cat "$1" | head -2 | tail -1 | tr -d '\b'`

	# Decrypt keys
	aeskey2=`echo -n "$aeskey" | base64 -d | openssl rsautl -decrypt -inkey "$2" -in /dev/stdin -out /dev/stdout`
	iv2=`echo -n "$iv" | base64 -d | openssl rsautl -decrypt -inkey "$2" -in /dev/stdin -out /dev/stdout`

	# Decrypt
	cat "$1"|tail -1|tr -d '\b'|base64 -d| openssl enc -d -aes-256-cbc -in /dev/stdin -out /dev/stdout -K "$aeskey2" -iv "$iv2"
fi


