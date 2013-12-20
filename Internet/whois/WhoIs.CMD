/* WhoIs.CMD */
PARSE ARG next
DO FOREVER
   IF next<>'' THEN WHOIS next
   PARSE PULL next
END
