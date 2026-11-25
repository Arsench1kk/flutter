#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
status=0

if violations=$(grep -rl 'package:http' lib/ | grep -Ev '^lib/core/api/|_repository\.dart$'); then
  printf '%s\n' "$violations"
  status=1
fi

if violations=$(grep -rl 'package:flutter/material' lib/ | grep -E '^lib/core/api/|_model\.dart$|_repository\.dart$'); then
  printf '%s\n' "$violations"
  status=1
fi

exit "$status"
