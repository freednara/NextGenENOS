#!/bin/bash

# ENOS Demo Org Creator
# Creates a demo-ready org with Enterprise features for client presentations
#
# Usage: ./scripts/create-demo-org.sh [org-alias] [duration-days]

ORG_ALIAS=${1:-"Demo-$(date +%m%d)"}
DURATION=${2:-30}

echo "🎯 Creating ENOS Demo Org..."
echo "  Alias: $ORG_ALIAS"
echo "  Duration: $DURATION days"
echo "  Type: Enterprise Demo with LiveAgent & Knowledge"
echo ""

./scripts/create-enos-org.sh "$ORG_ALIAS" "$DURATION" demo

echo ""
echo "🎉 Demo org '$ORG_ALIAS' ready for client presentations!"
echo "   Features: Enterprise edition, LiveAgent, Knowledge, Email-to-Case"
echo "   Duration: $DURATION days"
echo ""
echo "Quick access: sf org open --target-org $ORG_ALIAS"
