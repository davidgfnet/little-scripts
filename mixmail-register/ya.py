
# Ya/Mixmail inifinite emails registration!
# David G.F. <david@davidgf.ent>
#
# Register a range of accounts @mixmail.com
# Specify the low/high values for the range
# Enjoy!

import sys, os

low=int(sys.argv[1])
high=int(sys.argv[2])

countries = [276,252,253,294,277,254,278,279,280,255,256,257,258,281,259,260]

for counter in xrange(low,high):
	username="mylusername_num_"+str(counter)
	password="thisisthepass"
	year="198"+str(counter%10)
	country=str(countries[counter%len(countries)])

	request = "http://red.ya.com/SMain"

	ref = "http://red.ya.com/jif/redya/registro/JRegistroPortada.jsp?SITE=mixmail&TIPO=1"

	agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/10.0.0.0"

	pdata  = "REG_NICK=" + username + "&REG_PWD1=" + password + "&REG_PWD2=" + password
	pdata += "&REG_HASEMAIL=1&REG_EMAILACTIVATE=1"
	pdata += "&REG_QUESTION=bla&REG_ANSWER=ueyvvryg"
	pdata += "&REG_DAYBORN=01&REG_MONTHBORN=04&REG_YEARBORN=" + year
	pdata += "&REG_IDGENDER=1&REG_IDCOUNTRY=" + country + "&REG_CONDITIONS=1&REG_CONDITIONS_COMMERCIAL=1"
	pdata += "&NEW_NICK=&M=register4&UE=&HE="

	command = "wget -O /dev/null --user-agent=\"" + agent + "\" --referer=\"" + ref + "\" --post-data=\"" + pdata + "\" \"" + request + "\""

	returnvalue=os.system(command)

	if (returnvalue == 0):
		print username

	#os.system("sleep 300")

