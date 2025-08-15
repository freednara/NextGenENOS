#!/bin/bash

# ENOS Test Org Creator
# Creates a testing/QA org with security restrictions
#
# Usage: ./scripts/create-test-org.sh [org-alias] [duration-days]

ORG_ALIAS=${1:-"Test-$(date +%m%d)"}
DURATION=${2:-7}

echo "🧪 Creating ENOS Test Org..."
echo "  Alias: $ORG_ALIAS"
echo "  Duration: $DURATION days"
echo "  Type: Testing/QA with security restrictions"
echo ""

./scripts/create-enos-org.sh "$ORG_ALIAS" "$DURATION" test

echo ""
echo "🧪 Test org '$ORG_ALIAS' ready for QA!"
echo "   Features: Developer edition, secure settings, no admin bypass"
echo "   Duration: $DURATION days"
echo "   Perfect for: QA testing, UAT, security validation"
echo ""
echo "Quick access: sf org open --target-org $ORG_ALIAS"
