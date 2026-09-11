#!/bin/zsh
# Usage: ./tool/build_brand_apk.zsh <medifit|mednovations> <https-api-url> [api-path-prefix]

set -euo pipefail

if (( $# != 2 && $# != 3 )); then
  print -u2 'Usage: ./tool/build_brand_apk.zsh <medifit|mednovations> <https-api-url> [api-path-prefix]'
  exit 64
fi

brand="$1"
api_url="$2"
api_path_prefix="${3:-/api/v1}"

if [[ "$brand" != 'medifit' && "$brand" != 'mednovations' ]]; then
  print -u2 'Brand must be medifit or mednovations.'
  exit 64
fi
if [[ "$api_url" != https://* ]]; then
  print -u2 'A public HTTPS API URL is required.'
  exit 64
fi
if [[ "$api_path_prefix" != /* ]]; then
  print -u2 'The API path prefix must begin with /.'
  exit 64
fi

script_dir="${0:A:h}"
app_dir="${script_dir:h}"
workspace_dir="${app_dir:h}"
version_file="$app_dir/config/versions/$brand.env"
source "$version_file"

if [[ -z "${BUILD_NAME:-}" || -z "${BUILD_NUMBER:-}" ]]; then
  print -u2 "Invalid version configuration: $version_file"
  exit 1
fi
if [[ "$brand" == 'mednovations' ]]; then
  firebase_config="$app_dir/android/app/src/mednovations/google-services.json"
  if [[ ! -r "$firebase_config" ]]; then
    print -u2 'Mednovations Firebase is not configured.'
    print -u2 "Add its Android configuration at: $firebase_config"
    exit 1
  fi
fi

flutter_bin="$workspace_dir/.tools/flutter/bin/flutter"
if [[ ! -x "$flutter_bin" ]]; then
  print -u2 "Workspace Flutter SDK is unavailable: $flutter_bin"
  exit 1
fi

"$flutter_bin" build apk --release \
  --flavor="$brand" \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER" \
  --dart-define="APP_BRAND=$brand" \
  --dart-define="API_BASE_URL=$api_url" \
  --dart-define="API_PATH_PREFIX=$api_path_prefix"
