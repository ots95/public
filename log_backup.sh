#!/bin/sh
#TODAY=`date +%Y%m%d`
dayago=`date -d '1 day ago' '+%Y-%m-%d'`

# format = .log, .out, .txt

### First / LOG GZIP
#날짜붙이는거 소스단에서 설정되어있음.

find '/LOG/' -name *.log -exec gzip -f -v {} \;
find '/LOG/' -name *.out -exec gzip -f -v {} \;
find '/LOG/' -name *.txt -exec gzip -f -v {} \;

#find '/LOG/bhc-online/' ! -name "*.gz"  -and ! -newermt $date -and ! -name "pid.log"  -exec gzip -f -v {} \;
#find '/LOG/tomcat/spdp-online/' ! -name "*.gz"  -and ! -newermt $date -and ! -name "pid.log"  -exec gzip -f -v {} \;


### Second / LOG COPY
rsync -auvz /LOG/nginx/*.gz root@[IP_ADDR]:/LOG/r-seven11-api-001/nginx/
rsync -auvz /LOG/orderapi-retail/*.gz root@[IP_ADDR]:/LOG/r-seven11-api-001/orderapi-retail/
rsync -auvz /LOG/posapi-seven11/*.gz root@[IP_ADDR]:/LOG/r-seven11-api-001/posapi-seven11/
rsync -auvz /LOG/tomcat/orderapi-yogiyo-seven11/*.gz root@[IP_ADDR]:/LOG/r-seven11-api-001/tomcat/orderapi-yogiyo-seven11/
rsync -auvz /LOG/tomcat/posapi-seven11/*.gz root@[IP_ADDR]:/LOG/r-seven11-api-001/tomcat/posapi-seven11/


### Third / LOG DELETE
find /LOG/ -name '*.*' -mtime +2 -delete