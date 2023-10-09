#!/bin/bash
#
#rabbitmq 서버에서 특정 로그 발견 시, AWS WAF에 ip 차단 등록
#
tail -n 1 -f /root/script/test.log | grep --line-buffered "unparseble payload" | while read line
 
do
        echo "$line"
        bot_ip0=$(echo "$line" | awk '{print $3}')
        echo "$bot_ip0"
        bot_ip="$bot_ip0/32"
        echo "$bot_ip"
 
        aws wafv2 get-ip-set --name test --id [RESOURCE_ID] --scope REGIONAL > /root/script/test_info.json
        cat /root/script/test_info.json
 
        lock_token=$(cat /root/script/test_info.json | jq -r '.LockToken')
        echo $lock_token
 
        jq '{Addresses: .IPSet.Addresses}' test_info.json > input.json  #기존 ip-set에 등록되어 있던 ip들을 json형식으로 저장(백업)
        jq '.Addresses += ["'"$bot_ip"'"]' input.json > input_new.json  #신규로 등록할 ip를 백업ip.json파일에 추가
 
        aws wafv2 update-ip-set --name test --id [RESOURCE_ID] --scope REGIONAL --cli-input-json file://input_new.json --lock-token "$lock_token"  #json파일을 넣어서 ip지정
        date=$(date +%Y%m%d)
        echo $date $bot_ip >> blocked_ip.log
 
 
done
 
 
seven_days_ago=$(date -d "1 week ago" +%Y%m%d)   # 일주일전 날짜를 변수에 저장
blocked_date=$(cat blocked_ip.log | awk 'NR==1 {print $1}')   #blocked_ip.log에서 첫번째줄, 첫번째단어를 변수에 저장
blocked_ip=$(cat blocked_ip.log | awk 'NR==1 {print $2}')     #blocked_ip.log에서 첫번째줄, 두번째단어를 변수에 저장
 
if [ $seven_days_ago -ge $blocked_date ]    #7일전 날짜가 ip차단한 날짜보다 크거나 같다면 (이후라면) 동작
then
        aws wafv2 get-ip-set --name test --id [RESOURCE_ID] --scope REGIONAL > /root/script/test_info.json
        lock_token=$(cat /root/script/test_info.json | jq -r '.LockToken')
 
        jq '{Addresses: .IPSet.Addresses}' test_info.json > input.json   #ip-set에 등록되어있는 addresses를 받아와서 json파일로 저장
        jq -i --arg blocked_ip "$blocked_ip" '.Addresses |= map(select(. != $blocked_ip))' input.json   #addresses가 저장되어있는 json파일에서 등록한지 7일 지난 ip만 삭제
 
        aws wafv2 update-ip-set --name test --id [RESOURCE_ID] --scope REGIONAL --cli-input-json file://input.json --lock-token "$lock_token"    #새로운 addresses로 ip-set update
 
        sed -i '1d' blocked_ip.log   #blocked_ip.log 에서 첫번째줄을 삭제.
 
fi