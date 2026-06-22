# Apple Foundation Models Photo Rater

Batch-rate a folder of photos with Apple Foundation Models through the `fm` CLI and export the results to CSV.

This repo is a small experimental shell utility for first-pass photo review. It loops through local image files, sends each image to `fm respond --image`, asks for a quality score, extracts the numeric rating, and writes the result to a CSV file. - can also be easily modified/used as a general apple foundation model vision batch processing script. edit prompt to whatever you need

## What it does

- Rates photos on a `1-50` quality scale.
- Uses a customizable prompt for focus, lighting, sharpness, noise, subject strength, and composition.
- Exports `filename`, `rating`, and `response` to CSV.
- Helps surface stronger images before manual curation.

## Requirements

- macOS with Apple Intelligence / Foundation Models access
- `fm` CLI installed and working
- `zsh`
- A local folder of images

Test one image first:

```zsh
fm respond --image /path/to/photo.png "Rate image quality on a scale of 1-50. Start with Rating:"
```

## Quick start

```zsh
git clone https://github.com/Newport1/Apple-Foundational-Model-Photo-rating.git
cd Apple-Foundational-Model-Photo-rating
chmod +x rate_images_fm.zsh
./rate_images_fm.zsh /path/to/image/folder /path/to/output.csv
```

Example:

```zsh
./rate_images_fm.zsh /Users/user1/Desktop/DCIM/100NZ6_2 /Users/user1/Desktop/image_ratings.csv
open /Users/user1/Desktop/image_ratings.csv
```

## Output

```csv
filename,rating,response
photo_001.png,42,"Rating: 42. Strong focus, clean light, and balanced composition."
```

## Usage note

`fm respond --image` expects a single image file, not a folder. This script handles that by looping through the folder and passing each image file individually.

## Limitations

- Ratings are model judgments, not objective measurements.
- Use results for triage, not final selection.
- The script is intentionally minimal and processes files sequentially.

## License

MIT
