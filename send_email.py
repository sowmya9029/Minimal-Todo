# Python code to illustrate Sending mail from  your Gmail account
import smtplib
import sys

email_from = ""
email_pwd = ""
email_to = sys.argv[1]

# creates SMTP session
s = smtplib.SMTP('smtp.gmail.com', 587)

# start TLS for security
s.starttls()

# Authentication
s.login(email_from, email_pwd)

# message to be sent
message = '''\
Subject: {0}


{1}
'''.format(sys.argv[2], open(sys.argv[3], 'r').read())

# sending the mail
s.sendmail(email_from, email_to, message)

print("email sent successfully")
# terminating the session
s.quit()
