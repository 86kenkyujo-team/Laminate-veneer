#!/bin/sh
set -eu

public_url="https://laminate-veneer.vercel.app/renewal-demo"
public_host="laminate-veneer.vercel.app"
expected_remote="86kenkyujo-team/Laminate-veneer.git"
expected_project='"projectName":"laminate-veneer"'
commit_message=${1:-"Update laminate veneer LP"}

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

current_root=$(git rev-parse --show-toplevel)
if [ "$current_root" != "$repo_root" ]; then
  printf 'Wrong repository root: %s\nExpected: %s\n' "$current_root" "$repo_root" >&2
  exit 1
fi

remote_url=$(git remote get-url origin)
case "$remote_url" in
  *"$expected_remote") ;;
  *)
    printf 'Wrong Git remote: %s\nExpected remote containing: %s\n' "$remote_url" "$expected_remote" >&2
    exit 1
    ;;
esac

if ! tr -d '[:space:]' < .vercel/project.json | grep -q "$expected_project"; then
  printf 'Wrong Vercel project. Expected laminate-veneer in .vercel/project.json\n' >&2
  exit 1
fi

branch=$(git branch --show-current)
if [ -z "$branch" ]; then
  printf 'Cannot push from detached HEAD.\n' >&2
  exit 1
fi

git add -A
sh scripts/check-new-image-sizes.sh

if git diff --cached --quiet; then
  printf 'No local changes to commit. Pushing %s as-is.\n' "$branch"
else
  git commit -m "$commit_message"
fi

git push origin "$branch"

deploy_log=$(mktemp "${TMPDIR:-/tmp}/laminate-vercel-deploy.XXXXXX")
trap 'rm -f "$deploy_log"' EXIT HUP INT TERM

vercel --prod --yes | tee "$deploy_log"
deployment_url=$(
  grep -Eo 'https://laminate-veneer-[a-z0-9]+-86kenkyujo-teams-projects\.vercel\.app' "$deploy_log" |
    tail -1
)

if [ -z "$deployment_url" ]; then
  printf 'Could not detect Vercel production URL from deploy output.\n' >&2
  exit 1
fi

vercel alias set "$deployment_url" "$public_host"

curl -fsSI "$public_url" >/dev/null

printf '\nReady: %s\n' "$public_url"
