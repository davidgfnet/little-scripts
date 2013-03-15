
# Password field fetcher
# David Guillen Fandos <david@davidgf.net>
#
# This script reads a list of domains and performs a HTTP GET query
# to retrieve the front page. After this it tries to look for <input>
# fields which are a password box and prints them in stdout
#
# The purpose of the script is to get a statistic of the names
# of the user/pass fields in websites.
# Attached you can find a Top 1M website list (to try it)

import urllib
import urllib2
import re
import fileinput
import sys

user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
headers = { 'User-Agent' : user_agent }

def get_html_field(stri,nam):
	mo=re.match(r'.*' + nam +  '\s*=\s*["\'](.*?)["\']',stri)
	if (mo):
		return mo.group(1)
	return ""

for url in fileinput.input():
	if url[:4] != "http":
		url = "http://" + url

	try:
		sys.stderr.write("Querying " + url)
		req = urllib2.Request(url)
		response = urllib2.urlopen(req)
		the_page = response.read()
	except:
		sys.stderr.write("Error at " + url)
		the_page = ""

	matches = re.findall(r'<input\s+.*?>',the_page)
	
	if len(matches) > 0:
		user = ""
		passw = ""
		for match in matches:
			# Pass
			mo=re.match(r'.*type\s*=\s*["\']password["\']',match)
			if (mo):
				passw = get_html_field(match,"name")
	
			mo=re.match(r'.*type\s*=\s*["\']text["\']',match)
			if (mo):
				user = get_html_field(match,"name")
				
			if (user != "" and passw != ""):
				print user,passw
				user = ""
				passw = ""



