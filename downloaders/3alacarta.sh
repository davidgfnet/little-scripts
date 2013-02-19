
#
# 3alacarta vide downloader (by David G. F.)
#
# Usage 3alacarta.sh VideoID videofile
# Requires rtmpdump, wget and awk installes


url=`wget -q  -O - "http://www.tv3.cat/su/tvc/tvcConditionalAccess.jsp?ID=$1&QUALITY=H&FORMAT=MP4" | awk 'BEGIN { FS = "rtmp" } ; { print $2 }' | awk 'BEGIN {  FS = "?auth" } ; { print $1 }' | sed '/^$/d' | awk '{ print "rtmp"$0; }'`

rtmpdump -r "$url" -o $2 --resume


