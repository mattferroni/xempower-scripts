import smtplib

FROM = "marc.necst@gmail.com"
TO = ["andrea.corna.ac.91@gmail.com"]
SUBJECT = "[XARC1] - Test finished"
TEXT = "Test is terminated"
message = """\From: %s\nTo: %s\nSubject: %s\n\n%s""" % (FROM, ", ".join(TO), SUBJECT, TEXT)

def main():
	try:
		server = smtplib.SMTP("smtp.gmail.com", 587)
		server.ehlo()
		server.starttls()
		server.login("marc.necst@gmail.com", "marc.marc")
		server.sendmail(FROM, TO, message)
		server.close()
		print 'successfully sent the mail'
	except:
		print "failed to send mail"
main()