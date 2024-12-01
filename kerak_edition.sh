#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"
source $HOME/solana_bot/settings.sh
echo -e
date
$SOLANA_PATH validators -u$CLUSTER --output json-compact > $HOME/solana_bot/delinq$CLUSTER.txt
for index in ${!PUB_KEY[*]}
do
    PING=$(ping -c 4 ${IP[$index]} | grep transmitted | awk '{print $4}')
    DELINQUEENT=$(cat $HOME/solana_bot/delinq$CLUSTER.txt | jq '.validators[] | select(.identityPubkey == "'"${PUB_KEY[$index]}"'" ) | .delinquent ')
    BALANCE_TEMP=$(curl --silent -X POST $API_URL -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0", "id":1, "method":"getBalance", "params":["'${PUB_KEY[$index]}'"]}' | jq '.result.value')
    BALANCE=$(echo "scale=2; $BALANCE_TEMP/1000000000" | bc)
        
    if [[ $BALANCE == 0 ]]; then sleep 1
    BALANCE_TEMP=$(curl --silent -X POST $API_URL -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0", "id":1, "method":"getBalance", "params":["'${PUB_KEY[$index]}'"]}' | jq '.result.value')
    BALANCE=$(echo "scale=2; $BALANCE_TEMP/1000000000" | bc)
    fi
    simvol1=${BALANCE:0:1}
    if [[ $simvol1 = . ]]; then BALANCE="0$BALANCE"
    else BALANCE=$BALANCE
    fi
      
    if (( $(bc <<< "$BALANCE < ${BALANCEWARN[$index]}") )) 
    then
    echo "закончился баланс" ${TEXT_NODE[$index]}
curl --header 'Content-Type: application/json' --request 'POST' --data '{"chat_id":"'"$CHAT_ID_ALARM"'","text":"'"${BALANCE_ALARM[$index]}"' '"\nBalance:$BALANCE"' '"${PUB_KEY[$index]}"'"}' "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" 
    fi
    if [[ $PING == 0 ]] && [[ $DELINQUEENT == true ]]
    then
       echo ${INET_ALARM[$index]} ${TEXT_ALARM[$index]}
curl --header 'Content-Type: application/json' --request 'POST' --data '{"chat_id":"'"$CHAT_ID_ALARM"'","text":"'"${INET_ALARM[$index]}"' '"${TEXT_ALARM[$index]}"' '"${PUB_KEY[$index]}"'"}' "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    echo -e "\n"
    elif [[ $PING == 0 ]]
    then
       echo ${INET_ALARM[$index]}
curl --header 'Content-Type: application/json' --request 'POST' --data '{"chat_id":"'"$CHAT_ID_ALARM"'","text":"'"${INET_ALARM[$index]}"' '"${PUB_KEY[$index]}"'"}' "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    echo -e "\n"
    elif [[ $DELINQUEENT == true ]]
    then
       echo ${TEXT_ALARM[$index]}
curl --header 'Content-Type: application/json' --request 'POST' --data '{"chat_id":"'"$CHAT_ID_ALARM"'","text":"'"${TEXT_ALARM[$index]}"' '"${PUB_KEY[$index]}"'"}' "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    else
    echo "Все ok" ${PUB_KEY[$index]}
    fi
done

if (( $(echo "$(date +%M) < 5" | bc -l) )); then

gossip=$($SOLANA_PATH gossip -u$CLUSTER > $HOME/solana_bot/ip$CLUSTER.txt)
mesto_top_temp=$($SOLANA_PATH validators -u$CLUSTER --sort=credits -r -n > $HOME/solana_bot/mesto_top$CLUSTER.txt )
lider=$(cat $HOME/solana_bot/mesto_top$CLUSTER.txt | sed -n 2,1p |  awk '{print $3}')
lider2=$(cat $HOME/solana_bot/delinq$CLUSTER.txt | jq '.validators[] | select(.identityPubkey == "'"$lider"'") | .epochCredits ')
Average_temp=$(cat $HOME/solana_bot/delinq$CLUSTER.txt | jq '.averageStakeWeightedSkipRate')
Average=$(printf "%.2f" $Average_temp)
if [[ -z "$Average" ]]; then Average=0
   fi
  
RESPONSE_EPOCH=$($SOLANA_PATH epoch-info -u$CLUSTER > $HOME/solana_bot/temp$CLUSTER.txt)
EPOCH=$(cat $HOME/solana_bot/temp$CLUSTER.txt | grep "Epoch:" | awk '{print $2}')
EPOCH_PERCENT=$(printf "%.2f" $(cat $HOME/solana_bot/temp$CLUSTER.txt | grep "Epoch Completed Percent" | awk '{print $4}' | grep -oE "[0-9]*|[0-9]*.[0-9]*" | awk 'NR==1 {print; exit}'))"%"
END_EPOCH=$(echo $(cat $HOME/solana_bot/temp$CLUSTER.txt | grep "Epoch Completed Time" | grep -o '(.*)' | sed "s/^(//" | awk '{$NF="";sub(/[ \t]+$/,"")}1'))  
  
    for index in ${!PUB_KEY[*]}
    do
    ip=$(cat $HOME/solana_bot/ip$CLUSTER.txt | grep ${PUB_KEY[$index]} | awk '{print $1}')
    epochCredits=$(cat $HOME/solana_bot/delinq$CLUSTER.txt | jq '.validators[] | select(.identityPubkey == "'"${PUB_KEY[$index]}"'" ) | .epochCredits ')
    mesto_top=$(cat $HOME/solana_bot/mesto_top$CLUSTER.txt | grep ${PUB_KEY[$index]} | awk '{print $1}' | grep -oE "[0-9]*|[0-9]*.[0-9]")
    proc=$(bc <<< "scale=2; $epochCredits*100/$lider2")
    onboard=$(curl -s -X GET 'https://api.solana.org/api/validators/'"${PUB_KEY[$index]}" | jq -r '.onboardingNumber')
#dali blokov
    All_block=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{ "jsonrpc":"2.0","id":1, "method":"getLeaderSchedule", "params": [ null, { "identity": "'${PUB_KEY[$index]}'" }] }' | jq '.result."'${PUB_KEY[$index]}'"' | wc -l)
    All_block=$(echo "${All_block} -2" | bc)
    if (( $(bc <<< "$All_block < 0") )); then All_block=0
       fi
#done,sdelal,skipnul, skyp%
    BLOCKS_PRODUCTION_JSON=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1, "method":"getBlockProduction", "params": [{ "identity": "'${PUB_KEY[$index]}'" } ]}')
    Done=$(echo ${BLOCKS_PRODUCTION_JSON} | jq '.result.value.byIdentity."'${PUB_KEY[$index]}'"[0]')
    if (( $(bc <<< "$Done == null") )); then Done=0
        fi
    sdelal_blokov=$(echo ${BLOCKS_PRODUCTION_JSON} | jq '.result.value.byIdentity."'${PUB_KEY[$index]}'"[1]')
    if [[ -z "$sdelal_blokov" ]]; then sdelal_blokov=0
        fi
    skipped=$(bc <<< "$Done - $sdelal_blokov")
    
    skip=$(bc <<< "scale=2; $skipped*100/$Done")
    if [[ -z "$skip" ]]; then skip=0
        fi
       
    if (( $(bc <<< "$skip <= $Average + $skip_dop") )); then skip=🟢$skip
    else skip=🔴$skip
        fi
    
    BALANCE_TEMP=$(curl --silent -X POST $API_URL -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0", "id":1, "method":"getBalance", "params":["'${PUB_KEY[$index]}'"]}' | jq '.result.value')
    BALANCE=$(echo "scale=2; $BALANCE_TEMP/1000000000" | bc)
    simvol1=${BALANCE:0:1}
    if [[ $simvol1 = . ]]; then BALANCE="0$BALANCE"
    else BALANCE=$BALANCE
    fi
    
    VOTE_BALANCE_TEMP=$(curl --silent -X POST $API_URL -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0", "id":1, "method":"getBalance", "params":["'${VOTE[$index]}'"]}' | jq '.result.value')
    VOTE_BALANCE=$(echo "scale=2; $VOTE_BALANCE_TEMP/1000000000" | bc)
    simvol1=${VOTE_BALANCE:0:1}
    if [[ $simvol1 = . ]]; then VOTE_BALANCE="0$VOTE_BALANCE"
    else VOTE_BALANCE=$VOTE_BALANCE
    fi
    
    RESPONSE_STAKES=$($SOLANA_PATH stakes ${VOTE[$index]} -u$CLUSTER --output json-compact)
    ACTIVE=$(echo "scale=2; $(echo $RESPONSE_STAKES | jq -c '.[] | .activeStake' | paste -sd+ | bc)/1000000000" | bc)
    ACTIVATING=$(echo "scale=2; $(echo $RESPONSE_STAKES | jq -c '.[] | .activatingStake' | paste -sd+ | bc)/1000000000" | bc)
    if (( $(echo "$ACTIVATING > 0" | bc -l) )); then ACTIVATING=$ACTIVATING🟢
        fi
    DEACTIVATING=$(echo "scale=2; $(echo $RESPONSE_STAKES | jq -c '.[] | .deactivatingStake' | paste -sd+ | bc)/1000000000" | bc)
    if (( $(echo "$DEACTIVATING > 0" | bc -l) )); then DEACTIVATING=$DEACTIVATING⚠️
        fi

    VER=$(cat $HOME/solana_bot/delinq$CLUSTER.txt | jq '.validators[] | select(.identityPubkey == "'"${PUB_KEY[$index]}"'" ) | .version '| sed 's/\"//g')
    
    comission=$(bc <<< "scale=3; (($epochCredits*5) - ($sdelal_blokov*3750))/1000000")
    minus=${comission:0:1}
    if [[ $minus = - ]]; then comission=$(bc <<< "scale=3; $comission * -1")
       simvol1=${comission:0:1}
       if [[ $simvol1 = . ]]; then comission="earn 0$comission"
       else comission="earn $comission"  
         fi
    fi   

    if [[ $minus = . ]]; then comission=0$comission
    else comission=$comission
    fi
    
    PUB=$(echo ${PUB_KEY[$index]:0:10})
    info='"
<b>'"${TEXT_NODE[$index]}"'</b> '"[$PUB]"' ['"$VER"']
'"$ICON_IP $ip"'<code>
'"All:"$All_block" Done:"$Done" skipped:"$skipped""'
'"skip:"$skip%" Average:"$Average%""'
сredits >['"$epochCredits"'] ['"$proc"'%]
mesto>['"$mesto_top"'] onboard > ['"$onboard"']
active_stk >>>['"$ACTIVE"']
activating >>>['"$ACTIVATING"']
deactivating >['"$DEACTIVATING"']
balance>['"$BALANCE"']  
vote_balance>>['"$VOTE_BALANCE"']
comission>['"$comission"' sol]</code>"'
    
    if [[ $onboard == null ]]; then info='"
<b>'"${TEXT_NODE[$index]}"'</b> '"[$PUB]"' ['"$VER"']
'"$ICON_IP $ip"'<code>
'"All:"$All_block" Done:"$Done" skipped:"$skipped""'
'"skip:"$skip%" Average:"$Average%""'
сredits >['"$epochCredits"'] ['"$proc"'%]
mesto>['"$mesto_top"'] 
active_stk >>>['"$ACTIVE"']
activating >>>['"$ACTIVATING"']
deactivating >['"$DEACTIVATING"']
balance>['"$BALANCE"']  
vote_balance>>['"$VOTE_BALANCE"']
comission>['"$comission"' sol]</code>"'
       fi

    if [[ $CLUSTER == m ]]; then info='"
<b>'"${TEXT_NODE[$index]}"'</b> '"[$PUB]"' ['"$VER"']
'"$ICON_IP $ip"'<code>
'"All:"$All_block" Done:"$Done" skipped:"$skipped""'
'"skip:"$skip%" Average:"$Average%""'
сredits >['"$epochCredits"'] ['"$proc"'%]
mesto>['"$mesto_top"'] 
active_stk >>>['"$ACTIVE"']
activating >>>['"$ACTIVATING"']
deactivating >['"$DEACTIVATING"']
balance>['"$BALANCE"']  
vote_balance>>['"$VOTE_BALANCE"']
comission>['"$comission"' sol]</code>"'
       fi
    echo "Нода в порядке" ${TEXT_NODE[$index]}
curl --header 'Content-Type: application/json' --request 'POST' --data '{"chat_id":"'"$CHAT_ID_LOG"'",
"text":'"$info"',  "parse_mode": "html"}' "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    echo -e "\n"
done

       if (( $(echo "$(date +%H) == $TIME_Info2" | bc -l) )) && (( $(echo "$(date +%M) < 5" | bc -l) )); then
       for index in ${!PUB_KEY[*]}
       do

       info2=$(curl -s -X GET 'https://api.solana.org/api/validators/'"${PUB_KEY[$index]}")
       state=$(echo "$info2" | jq -r '.state')
       kycStatus=$(echo $info2 | jq '.kycStatus' | sed 's/\"//g')

       PUB=$(echo ${PUB_KEY[$index]:0:8})
       info2='"
<b>'"${TEXT_NODE2[$index]} epoch $EPOCH"'</b>['"$PUB"'] <code></code>
'"$icon_state SFDP:<b>$state</b>"'<code>
'"$icon_kycStatus $kycStatus"'</code>"'
curl --header 'Content-Type: application/json' --request 'POST' --data '{"chat_id":"'"$CHAT_ID_LOG"'",
"text":'"$info2"',  "parse_mode": "html"}' "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
       done         
         fi
    EPOCH=$(cat $HOME/solana_bot/temp$CLUSTER.txt | grep "Epoch:" | awk '{print $2}')
    echo "$TEXT_INFO_EPOCH" 
curl --header 'Content-Type: application/json' --request 'POST' --data '{"chat_id":"'"$CHAT_ID_LOG"'","text":"<b>'"$TEXT_INFO_EPOCH"'</b> <code>
['"$EPOCH"'] | ['"$EPOCH_PERCENT"'] 
End_Epoch '"$END_EPOCH"'</code>", "parse_mode": "html"}' "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
fi
