# LWC Component Visibility Issue - Solution Guide

## Problem Summary
**Issue**: LWC components are not appearing in the Experience Cloud page builder despite successful deployment.

**User Report**: "I still don't see the lwcs when attempting to add them to the community page"

## Root Cause Identified ✅
The LWC components are **successfully deployed** but not visible due to the **Experience Cloud site status**.

### Technical Details
- **LWC Components**: ✅ All 11 core ENOS components successfully deployed
- **Experience Cloud Site**: 🔍 "ENOS" site exists but status is "UnderConstruction"
- **Component Status**: All components show "Created" status in deployment logs
- **Meta.xml Configuration**: ✅ Proper targets configured (`lightningCommunity__Page`, `lightningCommunity__Default`)

### Why This Happens
1. **Site Status**: Experience Cloud sites with "UnderConstruction" status don't show LWC components in page builder
2. **Component Registration**: Components need the site to be fully activated before they become available
3. **Target Visibility**: Even with correct meta.xml targets, components won't appear until site is live

## Solution Steps

### Step 1: Activate Experience Cloud Site (Manual)
1. Go to **Setup → Digital Experiences → All Sites**
2. Find the **"ENOS"** site in the list
3. Click the **gear icon (⚙️)** next to the ENOS site
4. Select **"Edit"** from the dropdown
5. Change the **"Status"** from **"UnderConstruction"** to **"Live"**
6. Click **"Save"**
7. Wait a few minutes for the site to fully activate

### Step 2: Verify Activation
After manual activation, run this command to verify:
```bash
sf apex run --target-org ENOS-Pattern-Test --file /dev/stdin <<< "
try {
    List<Network> networks = [SELECT Id, Name, Status, UrlPathPrefix FROM Network];
    for (Network net : networks) {
        System.debug('Site: ' + net.Name + ' - Status: ' + net.Status);
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
"
```

### Step 3: Verify Component Accessibility
Check if LWC components are now accessible:
```bash
sf apex run --target-org ENOS-Pattern-Test --file /dev/stdin <<< "
try {
    Type componentType = Type.forName('enosProductCatalog');
    System.debug('Component accessible: ' + componentType);
} catch (Exception e) {
    System.debug('Component not accessible: ' + e.getMessage());
}
"
```

## Expected Results After Activation
✅ **Experience Cloud site status** should change to "Live"  
✅ **LWC components** should appear in Experience Cloud page builder  
✅ **Components** should be available in Lightning App Builder  
✅ **Components** should work correctly on live Experience Cloud pages  

## If Components Still Don't Appear
1. **Check additional targets**: Consider adding `lightningCommunity__Widget` and `lightningCommunity__Theme` to meta.xml
2. **Verify deployment status**: Check Setup → Lightning Components
3. **Check for errors**: Review Setup → Deployment Status
4. **Refresh page builder**: Try refreshing the Experience Cloud page builder

## Automation Script
Use the provided script to check status and get verification commands:
```bash
./scripts/activate-experience-cloud-site.sh ENOS-Pattern-Test
```

## Key Learning
**Experience Cloud site status directly affects LWC component visibility**. Components may deploy successfully but won't appear in page builder until the site is fully activated.

## Documentation
- **Pattern #22**: Added to `ERROR_PATTERNS_ANALYSIS.md`
- **Activation Script**: `scripts/activate-experience-cloud-site.sh`
- **This Guide**: `LWC_VISIBILITY_SOLUTION.md`

## Next Steps
1. **Complete manual activation** of Experience Cloud site
2. **Verify component visibility** using provided commands
3. **Test components** in Experience Cloud page builder
4. **Report results** for further troubleshooting if needed
