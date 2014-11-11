#!/bin/bash

dir=$(dirname $0)

# for genre in anime cooking dance game play radio sing sport vocaloid
for genre in anime 
do
  echo $genre
  rankingUrl="http://www.nicovideo.jp/ranking/view/daily/$genre"
  dateNow=$(date +%Y%m%d%H)
  curl $rankingUrl > $dir/tmp/ranking_${dateNow}_${genre}

  length=$(cat $dir/tmp/ranking_${dateNow}_${genre} | wc -l)
  echo $length
  cat $dir/tmp/ranking_${dateNow}_${genre} | 
  grep -A $length 'videoRanking' | 
  grep -B $length 'column sub' | 
  grep -E '(count view|count comment|"rankingNum"|title|data-id=")' |
  sed 's/^ *//' | 
  grep -v "data-enable-uad" | 
  sed -e 's;<[^>]*>;;g' -e 's/\([0-9]\),\([0-9]\)/\1\2/g' | 
  sed -e 's/再生//' -e 's/コメ//g' | 
  grep -v "data-href" |
  sed 's;.*/watch/\(..[0-9]*\)".*;\1;' | 
  awk -v OFS="," '{print NR % 5, $0}' |
  sed -e 's/^1/rank/' -e 's/^[0234]//' | 
  tr '\n' ' ' | 
  gsed 's/ rank/\nrank/g' | 
  sed 's/^rank,//' | 
  sed 's/ ,/,/g'> $dir/log/ranking_${dateNow}_${genre}

  sleep 1
done

