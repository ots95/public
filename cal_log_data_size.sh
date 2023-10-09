#!/bin/bash

LOG_DIR="/ES"

# 어제 날짜 계산
yesterday=$(date --date="yesterday" "+%Y-%m-%d")

# 로그 파일 내에서 어제 날짜를 포함하는 파일을 찾아서 용량 계산
total_size=0
for logfile in $(find ${LOG_DIR} -type f -name "*${yesterday}*"); do
  file_size=$(du -b ${logfile} | cut -f1)
  total_size=$((total_size + file_size))
done

# 계산된 용량을 GB 단위로 변환
total_size_gb=$(echo "scale=2; ${total_size}/1024/1024/1024" | bc)

echo "Yesterday's total data size: ${total_size_gb} GB"