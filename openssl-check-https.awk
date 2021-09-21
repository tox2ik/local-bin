#!/bin/awk

BEGIN {
	cert=0
	buf[0]=""
	cert_line=0
}


/BEGIN/ {
	print ""
}
cert_line == 0 {
	print
}

/(-----)?BEGIN CERTIFICATE(-----)?/ || cert_line >= 1 {
	if (cert_line == 0) {
		cert_line=1
	}

	buf[cert_line]=$0
	cert_line++

}
/(-----)?END CERTIFICATE(-----)?/ {


	o=""
	for (i in buf) {
		# print buf[i], i
		o=o "\n" buf[i]
	}

	f= "/tmp/examine-cert-" cert ".crt"

	print o > f
	print "-----WRITTEN TO: " f

	for (i in buf) {
		buf[i]=""
	}

	cert_line=0
	cert++
}

