#!/usr/bin/env bash
#############################################################################
# migrate-volumes.sh
#
# Migrates data from Docker named volumes to bind-mount host paths before
# switching to the updated docker-compose.yaml (FIX-13).
#
# Run this ONCE with the stack DOWN before deploying the new compose.
# Safe to re-run — existing data is never deleted, only copied.
#
# Usage:
#   chmod +x migrate-volumes.sh
#   docker compose down
#   sudo ./migrate-volumes.sh
#   docker compose up -d
#############################################################################

set -euo pipefail

BASE=/var/local/dcm4chee-arc

echo "=== PACS volume migration ==="
echo "Target base directory: $BASE"
echo ""

# Ensure target directories exist with correct ownership
mkdir -p \
  "$BASE/ldap" \
  "$BASE/slapd.d" \
  "$BASE/arc-data" \
  "$BASE/storage" \
  "$BASE/db" \
  "$BASE/mysql" \
  "$BASE/re-brand"

echo "[1/3] Migrating pacs_ldap-data → $BASE/ldap"
if docker volume inspect pacs_ldap-data &>/dev/null; then
  docker run --rm \
    -v pacs_ldap-data:/source:ro \
    -v "$BASE/ldap":/dest \
    alpine sh -c "cp -av /source/. /dest/ && echo 'done'"
else
  echo "  Volume pacs_ldap-data not found — skipping (directory already empty or never created)"
fi

echo ""
echo "[2/3] Migrating pacs_ldap-config → $BASE/slapd.d"
if docker volume inspect pacs_ldap-config &>/dev/null; then
  docker run --rm \
    -v pacs_ldap-config:/source:ro \
    -v "$BASE/slapd.d":/dest \
    alpine sh -c "cp -av /source/. /dest/ && echo 'done'"
else
  echo "  Volume pacs_ldap-config not found — skipping"
fi

echo ""
echo "[3/3] Migrating arc_data → $BASE/arc-data"
if docker volume inspect arc_data &>/dev/null; then
  docker run --rm \
    -v arc_data:/source:ro \
    -v "$BASE/arc-data":/dest \
    alpine sh -c "cp -av /source/. /dest/ && echo 'done'"
else
  echo "  Volume arc_data not found — skipping"
fi

echo ""
echo "=== Migration complete ==="
echo ""
echo "Directory contents:"
for dir in ldap slapd.d arc-data; do
  count=$(find "$BASE/$dir" -mindepth 1 2>/dev/null | wc -l)
  echo "  $BASE/$dir — $count items"
done

echo ""
echo "Next steps:"
echo "  1. Verify the counts above look reasonable"
echo "  2. Run: docker compose up -d"
echo "  3. Confirm stack is healthy, then clean up old named volumes:"
echo "       docker volume rm pacs_ldap-data pacs_ldap-config arc_data"
echo "  4. Remove any remaining orphans:"
echo "       docker volume prune -f"
echo ""
echo "The old named volumes are NOT deleted by this script."
echo "Remove them manually only after confirming the stack is working."
