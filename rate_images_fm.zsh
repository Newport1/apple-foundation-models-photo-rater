#!/bin/zsh

folder=$1
out=${2:-$HOME/Desktop/image_ratings.csv}

prompt='rate image quality on scale of 1-50 based on focus lighting quality etc, reason and think about what makes a good composition before answering. Start the answer exactly like this: Rating: NUMBER'

if [[ -z "$folder" ]]; then
  echo "Usage: ~/rate_images_fm.zsh /folder/of/images /path/to/output.csv"
  exit 1
fi

if [[ ! -d "$folder" ]]; then
  echo "Folder not found: $folder"
  exit 1
fi

echo 'filename,rating,response' > $out

for img in $folder/*.(NEF|nef|JPG|jpg|JPEG|jpeg|PNG|png|HEIC|heic|DNG|dng)(N); do
  filename=${img:t}

  echo
  echo "Processing: $filename"
  echo "Running:"
  echo "fm respond --image $img \"$prompt\""

  response=$(fm respond --image $img "$prompt" 2>&1)
  code=$?

  if [[ $code -ne 0 ]]; then
    rating=""
    response="ERROR code $code: $response"
  else
    rating=$(echo "$response" | grep -Eio 'Rating:[[:space:]]*[0-9]+' | head -1 | grep -Eo '[0-9]+')
    if [[ -z "$rating" ]]; then
      rating=$(echo "$response" | grep -Eo '\b([1-4]?[0-9]|50)\b' | head -1)
    fi
  fi

  clean_response=$(echo "$response" | tr '\n' ' ' | sed 's/"/""/g')
  clean_filename=$(echo "$filename" | sed 's/"/""/g')

  echo "\"$clean_filename\",\"$rating\",\"$clean_response\"" >> $out

  echo "Rating: ${rating:-not found}"
done

echo
echo "Done:"
echo $out
