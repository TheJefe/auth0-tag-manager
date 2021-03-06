#!/bin/bash

MATCHER=${2:-"*"}
NPM_TAG=${3:-"beta"}

NPM_NAME=$(node tools/scripts/utils/attribute.js name)
VERSION=$(node tools/scripts/utils/attribute.js version)

NPM_BIN=$(npm bin)
STABLE=$($NPM_BIN/semver $VERSION -r "*")

# Enable failing on exit status here because semver exits with 1 when the range
# doesn't match.
set -e

new_line()
{
  echo ""
}

verbose()
{
  echo -e " \033[36m→\033[0m $1"
}

verbose_item()
{
  echo -e " \033[96m∙\033[0m $1"
}

success()
{
  echo -e " \033[1;32m✔︎\033[0m $1"
}

npm_release()
{
  verbose "Checking if version $1 of $NPM_NAME is already available in npm…"

  NPM_EXISTS=$(npm info -s $NPM_NAME@$1 version)

  if [ ! -z "$NPM_EXISTS" ] && [ "$NPM_EXISTS" == "$1" ]; then
    verbose "There is already a version $NPM_EXISTS in npm. Skipping npm publish…"
  else
    if [ ! -z "$STABLE" ]; then
      verbose "Deploying $1 to npm"
      npm publish
    else
      verbose "Deploying $1 to npm with tag $NPM_TAG"
      npm publish --tag "$NPM_TAG"
    fi
    success "$NPM_NAME uploaded to npm registry"
  fi
}

npm_release "$VERSION"
