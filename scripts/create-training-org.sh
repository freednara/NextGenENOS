#!/bin/bash

# ENOS Training Org Creator
# Creates a full-featured org for workshops and training sessions
#
# Usage: ./scripts/create-training-org.sh [org-alias] [duration-days]

ORG_ALIAS=${1:-"Training-$(date +%m%d)"}
DURATION=${2:-14}

echo "🎓 Creating ENOS Training Org..."
echo "  Alias: $ORG_ALIAS"
echo "  Duration: $DURATION days"
echo "  Type: Enterprise Training with all features"
echo ""

./scripts/create-enos-org.sh "$ORG_ALIAS" "$DURATION" test

echo ""
echo "🎓 Training org '$ORG_ALIAS' ready for workshops!"
echo "   Features: Enterprise edition, Flow, Knowledge, LiveAgent, Admin login"
echo "   Duration: $DURATION days"
echo "   Perfect for: Workshops, training sessions, demos"
echo ""
echo "Quick access: sf org open --target-org $ORG_ALIAS"
