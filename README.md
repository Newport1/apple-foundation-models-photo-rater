# Apple-Foundational-Model-Photo-rating
automated photo quality rating based on a simple prompt, get ratings for a folder of images and quickly find the best ones, as rated by apple local foundational model. Just testing what you can do with macOS 27, just a test script.







START AI SUMMARY 

FM Image Folder Rater

Batch-rates a folder of images using fm respond --image, one image at a time, and writes the results to a CSV file.

This is useful when the model does not have enough context to process many images at once. The script sends each image individually, captures the model response, extracts a numeric rating, and saves:

filename,rating,response

Requirements

* macOS or Linux shell
* zsh
* fm CLI installed and working
* Image files in a local folder

Test that fm works with one image first:

fm respond --image /path/to/image.NEF "rate image quality on scale of 1-50"

Supported Image Types

The script currently scans for:

NEF, JPG, JPEG, PNG, HEIC, DNG, TIF, TIFF

Quick Start

Create the script:

nano ~/rate_images_fm.zsh

Paste this:

#!/bin/zsh
folder=$1
out=${2:-$HOME/Desktop/image_ratings.csv}
prompt='Rate image quality on a scale of 1-50 based on focus, lighting quality, exposure, color, contrast, sharpness, noise, subject strength, and composition. Think about what makes a good composition before answering.
Return exactly this format:
Rating: <1-50>
Response: <brief reasoning>'
if [[ -z "$folder" ]]; then
  echo "Usage: ~/rate_images_fm.zsh /folder/of/images /path/to/output.csv"
  exit 1
fi
if [[ ! -d "$folder" ]]; then
  echo "Folder not found: $folder"
  exit 1
fi
csv_escape() {
  local value="$1"
  value="${value//$'\n'/ }"
  value="${value//$'\r'/ }"
  value="${value//\"/\"\"}"
  printf '"%s"' "$value"
}
echo '"filename","rating","response"' > "$out"
for img in $folder/*.(NEF|nef|JPG|jpg|JPEG|jpeg|PNG|png|HEIC|heic|DNG|dng|TIF|tif|TIFF|tiff)(N); do
  filename=${img:t}
  echo
  echo "Processing: $filename"
  echo "Running: fm respond --image $img PROMPT"
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
  {
    csv_escape "$filename"
    printf ','
    csv_escape "$rating"
    printf ','
    csv_escape "$response"
    printf '\n'
  } >> "$out"
  echo "Rating: ${rating:-not found}"
done
echo
echo "Done:"
echo "$out"

Make it executable:

chmod +x ~/rate_images_fm.zsh

Run it:

~/rate_images_fm.zsh /path/to/image/folder /path/to/output.csv

Example:

~/rate_images_fm.zsh /Users/user1/Desktop/DCIM/100NZ6_2 /Users/user1/Desktop/image_ratings.csv

Output

The script creates a CSV file like:

"filename","rating","response"
"image.img","20","Rating: 20 Response: The image is slightly soft..."

Open the CSV:

open /Users/user1/Desktop/image_ratings.csv

Preview it in terminal:

head -5 /Users/user1/Desktop/image_ratings.csv

Important Notes

The script expects --image to receive an individual image file, not the folder itself.

Correct:

fm respond --image /folder/of/images/photo.NEF "prompt here"

Incorrect:

fm respond --image /folder/of/images "prompt here"

The script handles this by looping through the folder and passing each image file to fm respond --image.

Customizing the Prompt

Edit this section in the script:

prompt='Rate image quality on a scale of 1-50...'

For more consistent CSV parsing, keep this required output format in the prompt:

Rating: <1-50>
Response: <brief reasoning>

Troubleshooting

Run one image manually

fm respond --image /path/to/image.NEF "Rate image quality on a scale of 1-50. Start with Rating:"

If this fails, the script will fail too.

Debug the script

Run:

zsh -x ~/rate_images_fm.zsh /path/to/image/folder /path/to/output.csv

This prints each command as it runs.

CSV has blank ratings

The model may not be following the format. Strengthen the prompt:

Return exactly this format and nothing else:
Rating: <1-50>
Response: <brief reasoning>

Folder has spaces

This minimal version assumes paths do not contain spaces. For best results, use folders with simple paths, such as:

/Users/user1/Desktop/DCIM/100NZ6_2

Sorting Results by Rating

After generating the CSV, create a sorted copy:

python3 - <<'PY'
import csv
from pathlib import Path
src = Path("/Users/user1/Desktop/image_ratings.csv")
dst = Path("/Users/user1/Desktop/image_ratings_sorted.csv")
with src.open("r", encoding="utf-8", newline="") as f:
    rows = list(csv.DictReader(f))
def rating_value(row):
    try:
        return int(row.get("rating") or 0)
    except ValueError:
        return 0
rows.sort(key=rating_value, reverse=True)
with dst.open("w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["filename", "rating", "response"])
    writer.writeheader()
    writer.writerows(rows)
print(dst)
PY

Open the sorted CSV:

open /Users/user1/Desktop/image_ratings_sorted.csv
