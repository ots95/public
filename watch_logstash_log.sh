#!/bin/bash

log_file=/var/log/logstash/logstash-plain.log

#threshold=60

last_modification=$(stat -c "%Y" $log_file)
echo "last_modification : $last_modification"

while true
do
  sleep 60

  current_modification=$(stat -c "%Y" $log_file)
  echo "current_modificateion : $current_modification"

  time_diff=$((current_modification - last_modification))
  echo "time_diff : $time_diff"

  if [ $time_diff == 0 ];
  then
          echo "case 1 match, sleep 5sec"
          sleep 5
          if [ $time_diff == 0 ];
          then
                  echo "case 2 match"
                  echo "Log file has stopped updating!"
                  current_time=$(date "+%Y-%m-%d %H:%M:%S")
                  #json_string='{"text":"==========\n'
                  #json_string+="발생시간 : $current_time\n"
                  #json_string+='서버 : r-logstash-aws-01 ([IP_ADDR]) \n내용 : logstash service stopped\n=========="}'

                  json_string='{
                  "text": "==========\n발생시간 : '$current_time'\n서버 : r-logstash-aws-01 ([IP_ADDR]) \n내용 : logstash service stopped\n==========",
                  "username": "Logstash_alert",
                  "icon_emoji": ":rotating_light:
          }'
                  curl -X POST -H 'Content-type: application/json' --data "$json_string" https://hooks.slack.com/[SLACK_URL]
                  curl -X POST -H 'Content-type: application/json' --data "$json_string" https://hooks.slack.com/services/[SLACK_URL]

          #break

          else
                  break
          fi
    #break
  else
    last_modification=$current_modification
    echo "else_last_modification : $last_modification"
  fi
done