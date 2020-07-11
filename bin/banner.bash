#!/bin/bash
#
# Make your own gross random tiled banner
#
# ## Params
#
# 1.overlay the image that you are tiling
# 2.output the output file location
# 3.width the desired width
# 4.height the desired height
# 5.iterations how many images to add
#
# ## Usage
#
# ./banner.bash me-small.png output.png 854 300 400

set -efuo pipefail

create_bg() {
  local -r width="$1"
  local -r height="$2"
  local -r file="$3"

  convert -size "${width}x${height}" xc:none -depth 8 PNG24:"$file"
}

layer_at() {
  local -r bg="$1"
  local -r fg="$2"
  local -r output="$3"
  local -r x="$4"
  local -r y="$5"

  local page_x="+$x"
  local page_y="+$y"

  if (( x < 0 )); then
    page_x=$x
  fi
  if (( y < 0 )); then
    page_y=$y
  fi

  convert "$bg" -page "${page_x}${page_y}" "$fg" -flatten "$output"
}

random_position() {
  python <<EOF
import random
print(random.randint($1, $2))
print(random.randint($3, $4))
EOF
}

add_layer() {
  local -r current="$1"
  local -r width="$2"
  local -r height="$3"
  local -r overlay="$4"
  local -r overlay_width="$5"
  local -r overlay_height="$6"

  local -a coords=( $(random_position "-$overlay_width" "$width" "-$overlay_height" "$height") )

  mv "$current" "$TMP_FILE"
  layer_at "$TMP_FILE" "$overlay" "$current" "${coords[@]}"
}

main() {
  local -r overlay="$1"
  local -r output="$2"
  local -r width="$3"
  local -r height="$4"
  local -r iterations="$5"

  local -a overlay_dimmensions=( $( identify -format "%[fx:w] %[fx:h]" "$overlay" ) )

  create_bg "$width" "$height" "$output"
  for ((i=0 ; i < iterations ; i++)); do
    add_layer "$output" "$width" "$height" "$overlay" "${overlay_dimmensions[@]}"
  done
}

TMP_FILE=$(mktemp -t tmp.XXXXXXXXXX.png)

main "$@"
