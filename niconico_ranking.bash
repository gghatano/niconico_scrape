#!/bin/bash

dir=$(dirname $0)

for genre in anime cooking dance game play radio sing sport vocaloid
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
  grep -E '(count view|count comment|"rankingNum"|title)' | 
  sed 's/<[^>]*>/ /g'  | 
  grep -v "data-href" | 
  sed 's/^ *//' | 
  sed -e 's/再生//' -e "s/コメ//" |
  sed 's/\([0-9]\),\([0-9]\)/\1\2/' |
  sed 's/,/::/g' |
  awk -v OFS="," '{print int(NR%4),$0}' | 
  sed -e "s/^1/rank/" -e "s/^2/title/" -e "s/^3/view/" -e "s/^0/comment/" | 
  tr '\n' ',' | 
  gsed 's/rank/\nrank/g' | 
  sed -e 's/,title,/,/' -e "s/rank,//" -e "s/,view,/,/" -e "s/comment,//" -e "s/,$//" | 
  sed -e 's/ *,/,/g' -e 's/, */,/g' |
  grep -v "^\s*$" > $dir/log/ranking_${dateNow}_${genre}

  sleep 1
done

