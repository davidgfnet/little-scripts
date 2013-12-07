
username=$1
password=$2

tcookie=`mktemp`

# Get session cookie from front page
wget --keep-session-cookies --save-cookies $tcookie -O /dev/null "http://www.simyo.es" 2> /dev/null

# Auth
wget --load-cookies $tcookie --keep-session-cookies --save-cookies $tcookie --post-data="j_username=$username&j_password=$password" -O /dev/null "https://www.simyo.es/simyo/publicarea/login/j_security_check" 2> /dev/null

# Now get the consumption info
outdata1="`wget --load-cookies $tcookie -O - 'https://www.simyo.es/simyo/privatearea/ajax/customer/data-bundle.htm' 2>/dev/null`" 
outdata2="`wget --load-cookies $tcookie -O - 'https://www.simyo.es/simyo/privatearea/ajax/customer/data-bundle.htm' 2>/dev/null`"

used=`echo "$outdata1" | grep traficoDatosActual | grep -v text | cut -d "=" -f 2 | cut -d ";" -f 1 `
avail=`echo "$outdata2" | grep traficoDatosMaximo | grep -v text | cut -d "=" -f 2 | cut -d ";" -f 1 `

rm -f $tcookie

echo "Used data $used out of $avail"


