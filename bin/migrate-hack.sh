#!/usr/bin/env bash

ENV_FILE=""
COPY_DIR=""

renew_git() {
  if [[ -n $(git status --porcelain) ]]; then
    git stash -u > /dev/null
    git stash drop > /dev/null
  fi
}

if [[ -n $(git status --porcelain) ]]; then
  echo "[error] There are modified, deleted, or untracked files in the repository. Please resolve these changes before continuing."
  exit 1
fi

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --env)
      ENV_FILE="$2"
      shift 2
      ;;
    --env=*)
      ENV_FILE="${key#*=}"
      shift
      ;;
    --copy)
      COPY_DIR="$2"
      shift 2
      ;;
    --copy=*)
      COPY_DIR="${key#*=}"
      shift
      ;;
    *)
      echo "[debug] Ignoring unknown argument: $1"
      shift
      ;;
  esac
done

if [ -n "$ENV_FILE" ]; then
  echo "[env] Loading environment from $ENV_FILE"
  set -a
  source "$ENV_FILE"
  set +a
fi

if [ -n "$COPY_DIR" ]; then
  destination=$(pwd)
  if [ -d "$COPY_DIR" ]; then
    echo "[copy] Copying files from $COPY_DIR to $destination..."
    cp -r "$COPY_DIR/." "$destination"
  else
    echo "[copy] Directory not found: $COPY_DIR"
    exit 1
  fi
fi

echo "Detecting pending migrations..."

# 1. Get pending migrations list
PENDING_MIGRATIONS=$(bundle exec rails db:migrate:status | grep down | awk '{ print $2 }')
echo -e "\033[1;32mPending Migrations:\033[0m"
echo $PENDING_MIGRATIONS

# 2. [commit_date] [migration_id] [commit_hash]
MIGRATION_LIST=""
TEMP_FILE=$(mktemp)

# Build the file
for MIGRATION in $PENDING_MIGRATIONS; do
  FILE=$(find db/migrate -name "${MIGRATION}_*.rb")
  COMMIT_HASH=$(git log -n 1 --pretty=format:%H -- "$FILE")
  COMMIT_DATE=$(git show -s --format=%ct "$COMMIT_HASH")
  echo "$COMMIT_DATE $MIGRATION $COMMIT_HASH" >> "$TEMP_FILE"
done

# 3. Order list by commit date
while read -r TIMESTAMP MIGRATION COMMIT; do
  echo -e "\033[1;32mRunning migration $MIGRATION on commit $COMMIT (timestamp $TIMESTAMP)...\033[0m"
  renew_git
  CHECKOUT=$(git -c advice.detachedHead=false checkout "$COMMIT")

  cp -r "$COPY_DIR/." "$destination"

  CHECKOUT=$(bundle install > /dev/null)
  echo -e "\033[1;32m - migrate\033[0m"
  bundle exec rails db:migrate:up VERSION=$MIGRATION

  renew_git
  git checkout main > /dev/null
done < <(sort -n "$TEMP_FILE")

renew_git
bundle exec rails db:migrate:status | grep down

# Remove temp file
rm -f "$TEMP_FILE"
