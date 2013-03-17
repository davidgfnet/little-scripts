
#
# lasexta video downloader (by David G. F.)
#
# Usage lasexta.sh videourl videofilename
# Requires wget and awk installed

#url=`wget -q -O - "$1" | awk 'BEGIN { FS = "player_capitulo.xml=\x27" } ; { print $2 }' | awk 'BEGIN {  FS = "\x27" } ; { print $1 }'|head -n1 ` 

url=`wget -q -O - "$1" | grep "player_capitulo.xml='.*';" | sed -n "s/player_capitulo.xml='\(.*\)';/\1/p" |  sed 's/[^a-zA-Z0-9/\.]*//g' ` 

url=`wget -q  -O -  "http://www.lasexta.com/$url"  | sed -n "s/<\/archivo>/<\/archivo>/p" | grep "<archivo>.*mp4.*</archivo>" | head -n10 | sed -n "s/.*CDATA\[\(.*\)\]\].*/\1/p"  `

for i in $url;
do
	fn=`echo $i | sed -n "s/.*\/\([0-9]*\.mp4\).*/\1/p"`
	wget -c -O "$2$fn" "http://deslasexta.antena3.com/$i"
done



