#!/bin/bash

# ENOS Quick Org Creator
# Creates a minimal org for quick testing (no sample data, minimal features)
#
# Usage: ./scripts/create-quick-org.sh [org-alias]

ORG_ALIAS=${1:-"Quick-$(date +%H%M)"}

echo "⚡ Creating Quick ENOS Org..."
echo "  Alias: $ORG_ALIAS"
echo "  Duration: 1 day"
echo "  Type: Minimal (no sample data)"
echo ""

./scripts/create-enos-org.sh "$ORG_ALIAS" 1 quick

echo ""
echo "⚡ Quick org '$ORG_ALIAS' ready!"
echo "   Note: No sample data loaded - add manually if needed"
echo "   Add data: sf apex run --target-org $ORG_ALIAS --file scripts/apex/insert-basic-test-data.apex"
echo ""
echo "Quick access: sf org open --target-org $ORG_ALIAS"
