#!/bin/bash

usage() {
echo ""
    echo "Usage: $0 [-u <url>] [-l <list_path>] [-p <parameters_file>]"
    echo ""
    echo "Options:"
    echo "  -u <url>              Brute force parameters on a single URL"
    echo "  -l <list_path>        Brute force parameters on URLs from a list file"
    echo "  -p <parameters_file>  Path to the file containing the parameter names"
    echo ""
    echo "Examples:"
    echo "  $0 -u 'http://example.com' -p '/path/to/wordlist/parameters.txt'"
    echo "  $0 -l '/path/to/urls_to_test.txt' -p '/path/to/wordlist/parameters.txt'"
    echo ""
    echo "Note:"
    echo "  - If both -u and -l options are provided, please provide either -u or -l, not both."
    echo "  - The parameter file should contain one parameter per line."
    echo ""
    echo "For any questions or support, please contact me on Telegram: @whalebone7"
echo ""
    exit 1
}

while getopts ":u:l:p:" opt; do
    case $opt in
        u)
            url=$OPTARG
            ;;
        l)
            list_path=$OPTARG
            ;;
        p)
            parameters_file=$OPTARG
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            usage
            ;;
        *)
            usage
            ;;
    esac
done

echo " ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄▄▄▄▄▄▄▄▄▄▄"
echo "▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌"
echo "▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌          ▐░█▀▀▀▀▀▀▀█░▌"
echo "▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌"
echo "▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌          ▐░█▄▄▄▄▄▄▄█░▌"
echo "▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌"
echo "▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌          ▐░█▀▀▀▀▀▀▀█░▌"
echo "▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌"
echo "▐░▌       ▐░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌"
echo "▐░▌       ▐░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌"
echo " ▀         ▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀"


if [[ -n $url && -n $list_path ]]; then
    echo "Both URL and list path provided. Please provide either -u or -l option."
    usage
fi

if [[ -z $url && -z $list_path ]]; then
    echo "URL or list path not provided."
    usage
fi

if [[ -z $parameters_file ]]; then
    echo "Parameters file not provided."
    usage
fi

if [[ -n $url ]]; then
   
    { echo "${url}" | waybackurls | awk '!/\?|=/' | sort | uniq > links.txt; } &
    pid=$!

    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${spin:$i:1}"
        sleep 0.1
    done
    printf "\rWaybackurls is done.\n"


    excluded_extensions=("png" "jpg" "jpeg" "xls" "ppt" "mp3" "wav" "mp4" "avi" "zip" "pdf" "eof" "woff" "woff2" "css" "gif" "doc" "JPG" "ico")

   
    grep -vE "\.($(IFS="|"; echo "${excluded_extensions[*]}"))$" links.txt > links_filtered.txt
    mv links_filtered.txt links.txt

  
    { cat links.txt | httpx -nc -silent > links2.txt; } &
    pid=$!

    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${spin:$i:1}"
        sleep 0.1
    done
    printf "\rHttpx is done.\n"



spinning_symbols="/-\|"

while IFS= read -r parameter; do
    echo -e "\033[35mTrying\033[0m: '$parameter'"
    while IFS= read -r link; do
        if [[ $link == */ ]]; then
           
            link=${link%/}  
            url_with_param="${link}?${parameter}=whalebone"
        else
      
            url_with_param="${link}?${parameter}=whalebone"
        fi

    
        response_body=$(curl -s "$url_with_param")

        if [[ $response_body == *"${parameter}=whalebone"* ]]; then
            echo " " 
            echo -e "Parameter '$parameter' reflected: $url_with_param\r"
        else
            echo -ne "\r${spinning_symbols:0:1}"
        fi

       
        spinning_symbols="${spinning_symbols:1}${spinning_symbols:0:1}"
    done < links2.txt
done < "$parameters_file"


echo

  
    rm links.txt
    rm links2.txt

    echo "Done."
else
    if [[ ! -f $list_path ]]; then
        echo "List file does not exist."
        usage
    fi

    if [[ ! -f $parameters_file ]]; then
        echo "Parameters file does not exist."
        usage
    fi

    echo -e "\033[35mBrute forcing parameters on URLs from list file\033[0m: $list_path"
    while IFS= read -r link; do
        while IFS= read -r parameter; do
            if [[ $link == */ ]]; then
         
                url_with_param="${link}&${parameter}=whalebone"
            else
                
                url_with_param="${link}?${parameter}=whalebone"
            fi

           
            response_body=$(curl -s "$url_with_param")

            if [[ $response_body == *"${parameter}=whalebone"* ]]; then
                echo -e "Parameter '$parameter' reflected in URL: \033[32m$url_with_param\033[0m"
            fi
        done < "$parameters_file"
    done < "$list_path"

    echo "Done."
fi
