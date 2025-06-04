#!/usr/bin/env bash

# This script is designed to run pending migrations in a Rails application
# by checking out the commit where each migration was created.
# It also allows loading environment variables from a specified file and
# copying files from a specified directory to the current one.
# Usage: ./migrate-hack.sh [--env=FILE] [--copy=DIR] [--help] [--version]

VERSION="0.2.4"
ENV_FILE=""
COPY_DIR=""

# VERIFY GIT REPO
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "❌ [ERROR] - migrate-hack must be run inside a Git repository."
  exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# GETTING ARGS
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
    --help)
      echo "Usage: migrate-hack [--env=FILE] [--copy=DIR] [--help] [--version]"
      echo ""
      echo "Options:"
      echo "  --env=FILE     Load environment variables from the specified file"
      echo "  --copy=DIR     Copy config and settings untracked files from the specified directory to the current one"
      echo "  --help         Show this help message"
      echo "  --version      Show script version"
      exit 0
      ;;
    --version)
      echo "migrate-hack ($VERSION)"
      exit 0
      ;;
    *)
      echo "[debug] Ignoring unknown argument: $1"
      shift
      ;;
  esac
done

renew_git() {
  if [[ -n $(git status --porcelain) ]]; then
    git stash -u > /dev/null
    git stash drop > /dev/null
  fi
}

copy_files() {
  if [ -z "$COPY_DIR" ]; then
    echo "[copy] No copy directory specified. Skipping file copy."
    return
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
}

# BLOCKS

# UNCOMITTED CHANGES
if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️ [ERROR] - There are modified, deleted, or untracked files in the repository. Please resolve these changes to continue."
  exit 1
fi

# SERVER RUNNING
if [ -f tmp/pids/server.pid ]; then
  PID=$(cat tmp/pids/server.pid)
if ps -p "$PID" > /dev/null; then
    echo "🔍 Server is running on PID: $PID. Checking code reload settings..."

    # Verifica se cache_classes está true ou false
    CACHE_CLASSES=$(rails runner "puts Rails.application.config.cache_classes")
    EAGER_LOAD=$(rails runner "puts Rails.application.config.eager_load")

    if [ "$CACHE_CLASSES" = "false" ]; then
      echo "⚠️ [ERROR] - Server Rails/Puma is running with cache_classes=false (code reload ENABLED)."
      echo "💡 Please stop the server or use a separate repo/branch to avoid conflicts."
      exit 1
    else
      echo "✅ Server is running, but code reload is DISABLED (cache_classes=$CACHE_CLASSES, eager_load=$EAGER_LOAD). Safe to continue."
    fi
  fi
fi

# LOAD ENVIRONMENT
if [ -n "$ENV_FILE" ]; then
  echo "[env] Loading environment from $ENV_FILE"
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

# COPY FILES
copy_files

echo "Detecting pending migrations..."

# GET PENDING MIGRATIONS
MAX_ATTEMPTS=5
ATTEMPT=0

while true; do
  if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "⚠️ [WARNING] Please, if you have many newer migrations that fix older ones, run again."
    break
  fi

  PENDING_MIGRATIONS=$(bundle exec rails db:migrate:status | grep down | awk '{ print $2 }')

  if [ -z "$PENDING_MIGRATIONS" ]; then
    echo "✅ All migrations applied successfully."
    break
  fi

  echo -e "\033[1;32mPending Migrations:\033[0m"
  echo "$PENDING_MIGRATIONS"
  TEMP_FILE=$(mktemp)

  # BUILD LIST OF MIGRATIONS AND COMMITS
  for MIGRATION in $PENDING_MIGRATIONS; do
    FILE=$(find db/migrate -name "${MIGRATION}_*.rb")
    COMMIT_HASH=$(git log -n 1 --pretty=format:%H -- "$FILE")
    COMMIT_DATE=$(git show -s --format=%ct "$COMMIT_HASH")
    # [commit_date] [migration_id] [commit_hash]
    echo "$COMMIT_DATE $MIGRATION $COMMIT_HASH" >> "$TEMP_FILE"
  done

  # ORDER BY COMMIT DATE
  while read -r TIMESTAMP MIGRATION COMMIT; do
    echo -e "\033[1;32mRunning migration $MIGRATION on commit $COMMIT (timestamp $TIMESTAMP)...\033[0m"
    renew_git
    git -c advice.detachedHead=false checkout "$COMMIT" >/dev/null

    copy_files

    bundle install > /dev/null
    echo -e "\033[1;32m - migrate\033[0m"
    bundle exec rails db:migrate:up VERSION="$MIGRATION"

    renew_git
    git checkout "$CURRENT_BRANCH" > /dev/null
  done < <(sort -n "$TEMP_FILE")

  # RESTORING YOUR REPO
  renew_git

  # INCREMENT ATTEMPT COUNTER
  ATTEMPT=$((ATTEMPT + 1))
done

# TRASH
rm -f "$TEMP_FILE"
