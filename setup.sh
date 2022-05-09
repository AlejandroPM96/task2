#! /bin/bash
#functon for getting the date formatted for the file YYYYmmdd_hhmmss
get_formated_date(){
    c_date=$(echo $(date '+%Y-%m-%d %H:%M:%S') | sed 's/-//g' | sed 's/://g')
    c_date=${c_date/ /_}
    echo $c_date
}

#defining default values
frequency=5
filename="default"

#gathering options
while getopts "dD:f:n:" o; do
    case "${o}" in
        d)
            read -rep $'Do yo wish to delete all archived files? Y/N: ' message
            if [[ $message == "Y" || $message == "y" ]]; then 
                rm -r archieved
                exit
            else
                exit
            fi
            ;;
        f)
            frequency=${OPTARG,,}
            if [[ ! $frequency =~ [\d+(s|m)] ]];then
                echo "The frequency argument needs to be in the correct format"
                echo "Accepted formats: "
                echo -e "\t100s"
                echo -e "\t5m"
                echo -e "\t4seconds"
                echo -e "\t5min"
                exit
            fi
            ;;
        n)
            filename=${OPTARG}
            ;;
        *)
            echo "Invalid option"
    esac
done
echo "frequency: ${frequency} filename: ${filename}"

#Translate the frequency expression
declare freqNum
for (( i=0; i<${#frequency}; i++ )); do
    if [[ ${frequency:$i:1} == [s/m/sec/seconds/min/minutes] ]];then
        timeMeasure=${frequency:$i:1}
        break
    else
        freqNum+=${frequency:$i:1}
    fi
done
if [[ $timeMeasure == "m" ]];then
    frequency=$(($freqNum*60))
elif [[ $timeMeasure == "s" ]];then
    frequency=$freqNum
fi
echo "time measure: $timeMeasure -- in seconds: $frequency"

#Check for archive folder
ARCHIVE="archieved/"
if [ -d "$ARCHIVE" ]; then
    echo "archive directory exists"
else
    echo "Creating archive directory..."
    mkdir archieved
fi

#Creating the file
FILE="${filename}.txt"
if [ -f "$FILE" ]; then
    echo "File with name $FILE already exists"
else
    echo "Creating file..."
    touch ${FILE}
    chmod 777 $FILE 
fi

#Running the back-ups
while [ True ]
do
    echo "next archive in $frequency sec"
    sleep $frequency
    newDate="$(get_formated_date)"
    newName=$filename
    newName+="_$newDate.txt"
    echo "archived file: $newName"
    cp $FILE ./archieved/$newName
    cd archieved
    chmod 744 $newName
    cd ..
done