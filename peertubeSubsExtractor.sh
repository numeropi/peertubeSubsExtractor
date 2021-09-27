#!/bin/bash
# dependencies: jq, wget

urlVideoPeertube="$1"
protocol=$(echo "$urlVideoPeertube" | cut -d "/" -f 1 | cut -d ":" -f 1)
nodeDomain=$(echo "$urlVideoPeertube" | cut -d "/" -f 3)
flagIdentificationVersion=$(echo "$urlVideoPeertube" | cut -d "/" -f 4)
tmpFileSubs="/tmp/.subsPeertube.log"

function downloadSubs {
        while read urlSubtitles;
        do
                echo "$protocol://$nodeDomain$urlSubtitles"
                wget -q "$protocol://$nodeDomain$urlSubtitles"
        done < $tmpFileSubs
}

function countSubs {
        wget -q "$urlSubs" -O - | jq | grep -i "captionPath" | cut -d "\"" -f 4 > $tmpFileSubs
        echo "NUMBER OF SUBTITLES: $(cat $tmpFileSubs | wc -l)"
}

if [ $flagIdentificationVersion == "videos" ]
then
	videoID=$(echo "$urlVideoPeertube" | cut -d "/" -f 6)
        urlSubs="$protocol://$nodeDomain/api/v1/videos/$videoID/captions"
        echo " "
	echo "PEERTUBE VERSION: >3.3.0"
	echo "DOMAIN: $nodeDomain"
	echo "ID VIDEO: $videoID"
	echo "TARGET: $protocol://$nodeDomain/videos/watch/$videoID"
	echo "URL SUBS: $urlSubs"
	countSubs
	downloadSubs
        echo " "
else
        videoID=$(echo "$urlVideoPeertube" | cut -d "/" -f 5)
        urlSubs="$protocol://$nodeDomain/api/v1/videos/$videoID/captions"
	echo " "
        echo "PEERTUBE VERSION: <3.2.0"
        echo "DOMAIN: $nodeDomain"
        echo "ID VIDEO: $videoID"
        echo "TARGET: $protocol://$nodeDomain/w/$videoID"
        echo "URL SUBS: $urlSubs"
	echo " "
        countSubs
        downloadSubs
        echo " "
fi
