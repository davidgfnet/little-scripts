# Useful alias files

# Executable disasembling
f_disasm() {
	iself=`file "$1" | grep ELF`
	if [ -n "$iself" ]; then
		echo "Disasembling ELF x86 binary"
		objdump -D "$1" | gvim - 
	fi
	ispe=`file "$1" | grep PE32`
	if [ -n "$ispe" ]; then
		echo "Disasembling Win PE32 x86 binary"
		i686-w64-mingw32-objdump -D "$1" | gvim - 
	fi
	if [ -z "$ispe" -a -z "$iself" ]; then
		echo "Disasembling RAW x86 text & data"
		objdump -D --target binary -mi386 "$1" | gvim - 
	fi
}
alias disasm=f_disasm

# What's my ip?
f_myip() {
	wget -O - "http://iptools.bizhat.com/ipv4.php" 2> /dev/null
	echo ""
}
alias whatsmyip=f_myip

# NO-IP IP change
f_noip() {
	wget -O - "http://$1:$2@dynupdate.no-ip.com/nic/update?hostname=$3&myip=$4" 2> /dev/null
	echo ""
}
alias noip=f_noip

