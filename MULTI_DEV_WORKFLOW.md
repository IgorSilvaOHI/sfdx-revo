# Multi-Developer Safe Workflow

## Problem: 4 Developers Sharing Dev Sandbox

With multiple developers working in the same `dev` sandbox, you risk:
- Overwriting each other's work
- Breaking functionality
- Unable to rollback changes

## Solution: Git-First Development with Feature Branches

---

## Daily Safe Workflow (For Each Developer)

### Rule #1: ALWAYS Work on Feature Branches

```bash
# NEVER work directly on develop!
# ALWAYS create a feature branch first

git checkout develop
git pull origin develop
git checkout -b feature/igor/my-feature-name  # Use your name prefix
```

### Rule #2: Retrieve BEFORE You Deploy

```bash
# Before deploying YOUR changes, retrieve latest from dev
sf project retrieve start --target-org dev --manifest manifest/package.xml

# Check what changed
git status
git diff

# If there are conflicts, resolve them BEFORE deploying
```

### Rule #3: Small, Focused Deployments

```bash
# Deploy ONLY the files you changed, not everything
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls --target-org dev

# OR deploy from your feature branch commit
sf project deploy start --manifest manifest/my-feature.xml --target-org dev
```

### Rule #4: Commit Frequently

```bash
# Commit your work often (even work in progress)
git add .
git commit -m "WIP: Working on feature X"
git push origin feature/igor/my-feature-name

# This creates a backup in GitHub!
```

---

## Safe Development Process

### Step 1: Start Your Day

```bash
# Get latest code from ALL developers
git checkout develop
git pull origin develop

# Check dev sandbox for any changes you don't have
sf project retrieve start --target-org dev --manifest manifest/package.xml

# Review and commit any new changes
git add .
git commit -m "chore: Sync changes from dev sandbox"
git push origin develop
```

### Step 2: Create Your Feature Branch

```bash
# Name it with YOUR prefix so everyone knows it's yours
git checkout -b feature/igor/add-payment-logic

# Now you have a safe isolated branch
```

### Step 3: Develop & Test

```bash
# Make your changes locally
# Edit files in VS Code

# Deploy ONLY your specific files
sf project deploy start --source-path force-app/main/default/classes/PaymentController.cls --target-org dev

# Run tests
sf apex run test --class-names PaymentControllerTest --target-org dev
```

### Step 4: Commit & Push (Your Backup!)

```bash
# Commit frequently - this is your safety net!
git add force-app/main/default/classes/PaymentController.cls
git add force-app/main/default/classes/PaymentControllerTest.cls
git commit -m "feat: Add payment processing logic"
git push origin feature/igor/add-payment-logic

# ✅ Your work is now backed up in GitHub!
```

### Step 5: Before Final Deployment

```bash
# Retrieve latest from dev to catch any conflicts
sf project retrieve start --target-org dev --manifest manifest/package.xml

# If there are conflicts, resolve them
git status  # See what changed

# Merge develop into your feature branch
git checkout feature/igor/add-payment-logic
git merge develop  # This shows conflicts if any

# Resolve conflicts, then deploy again
sf project deploy start --source-path force-app/main/default/classes/ --target-org dev
```

### Step 6: Merge to Develop

```bash
# Once your feature is done and tested
git checkout develop
git pull origin develop  # Get latest
git merge feature/igor/add-payment-logic
git push origin develop

# Now other devs can get your changes
```

---

## Communication Protocol for Team

### Rule: Announce Before Deploying Large Changes

**In your team chat:**
```
@team I'm about to deploy changes to OpportunityTrigger in dev.
Please don't deploy trigger changes for next 15 min.
```

### Rule: Daily Sync

Every developer should:
1. **Morning:** Pull from GitHub develop branch
2. **Afternoon:** Push your feature branch (even if WIP)
3. **End of day:** Commit all work

---

## Rollback Strategy

### If You Break Something in Dev

**Option 1: Rollback Your Last Deployment**

```bash
# Find the commit before your change
git log --oneline

# Checkout that commit
git checkout <previous-commit-hash>

# Re-deploy the old version
sf project deploy start --source-path force-app/main/default/classes/BrokenClass.cls --target-org dev

# Return to your branch
git checkout feature/igor/my-feature
```

**Option 2: Revert a Specific File**

```bash
# Revert a file to previous version
git checkout HEAD~1 -- force-app/main/default/classes/BrokenClass.cls

# Deploy the reverted file
sf project deploy start --source-path force-app/main/default/classes/BrokenClass.cls --target-org dev
```

**Option 3: Emergency - Re-deploy from UAT or Prod**

```bash
# If dev is completely broken, retrieve from UAT/Prod
sf project retrieve start --source-path force-app/main/default/classes/BrokenClass.cls --target-org uat

# Deploy to dev
sf project deploy start --source-path force-app/main/default/classes/BrokenClass.cls --target-org dev
```

---

## Branch Naming Convention for Team

Everyone uses this pattern:
```
feature/<developer-name>/<description>
```

Examples:
- `feature/igor/payment-integration`
- `feature/maria/opportunity-validation`
- `feature/joao/email-templates`
- `bugfix/igor/null-pointer-fix`

This way you can see who owns each branch!

---

## Preventing Conflicts - Best Practices

### ✅ DO

- **Work on different files** - Coordinate with team
- **Pull frequently** - Get updates multiple times per day
- **Commit often** - Create savepoints
- **Use specific deployments** - Deploy only what you changed
- **Communicate** - Let team know what you're working on
- **Test in your feature branch** - Before merging to develop

### ❌ DON'T

- Deploy everything at once (`sf project deploy start`)
- Work directly on develop branch
- Go days without committing
- Deploy without retrieving first
- Modify the same file as another dev without coordinating

---

## File Ownership (Suggested)

To minimize conflicts, divide ownership:

| Developer | Primary Files |
|-----------|---------------|
| Igor | Payment classes, Opportunity trigger |
| Dev2 | Case trigger, Email templates |
| Dev3 | Flight management, Aeronave classes |
| Dev4 | Flows, Validation rules |

**If you need to modify someone else's file:**
1. Ask them first
2. Coordinate timing
3. Review together before deploying

---

## Emergency Contacts

If dev sandbox is broken:

1. **Notify team immediately** in team chat
2. **Don't panic** - everything is in Git
3. **Check Git history** to find last known good state
4. **Retrieve from UAT** if needed
5. **Ask for help** from senior dev

---

## Quick Reference

### Before ANY deployment:
```bash
git pull origin develop
sf project retrieve start --target-org dev --manifest manifest/package.xml
```

### Deploy only specific files:
```bash
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls --target-org dev
```

### If you broke something:
```bash
git checkout HEAD~1 -- force-app/main/default/classes/BrokenClass.cls
sf project deploy start --source-path force-app/main/default/classes/BrokenClass.cls --target-org dev
```

### Check who changed what:
```bash
git log --oneline force-app/main/default/classes/SomeClass.cls
git blame force-app/main/default/classes/SomeClass.cls
```

---

*Remember: Git is your safety net. Commit early, commit often!*

*Last Updated: 2025-10-14*
