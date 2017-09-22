#!/bin/bash
set -e

enc=gzip

SELF="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
LOGS="$SELF/logs"

source "$SELF/lib.sh"

{  echo -e "\n------< $(date) >------"
   while read line; do
      line=$(echo "$line" | tr -d '\r\n')
      echo $line
      if [[ "$line" =~ ^GET ]]; then
         GET=$(getpath $line)
      fi
      if [ "$line" == "" ]; then break; fi
   done
} > /dev/null # >> "$LOGS/requests" 9>> "$LOGS/paths"

case "$enc" in
   gzip    ) hdrs+=$(ce gzip) ; sf='gzip -c'  ;;
   deflate ) hdrs+=$(ce gzip) ; sf='bzip2 -c' ;;
   bzip2   ) hdrs+=$(ce bzip2); sf='bzip2 -c' ;;
   *       ) hdrs+=''         ; sf='cat'      ;;
esac

{  
   # echo "$(date '+%Y-%m-%d %H:%M:%S'): '$GET'" >&2
   if [ -f "$GET" ]; then                          
      headers "$(code 200)\n$(ext2mime $GET)\n$hdrs"
      $sf "$GET"
   elif [[ -d "$GET" || "$GET" == "" ]]; then      
      headers "$(code 200)\n$(cttext html)\n$hdrs"
      page "$(html title title)" "$(list "$GET")" | $sf
   else
      headers "$(code 200)\n$(cttext html)\n$hdrs" 
      notfound "$GET" | $sf
   fi
}
