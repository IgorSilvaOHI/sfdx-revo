# Scratch Org Development Guide - REVO

## Your Current Scratch Org

**Alias:** `igor-scratch` 🍁 (default)
**Username:** test-m7v5jnhflact@example.com
**Org ID:** 00D89000004dNMiEAM
**Status:** Active
**Expiration:** 2025-10-21 (7 days)

---

## Deployment Status

### Initial Deployment Results

```
✅ Successfully deployed: 3,315 components (73%)
❌ Failed to deploy: 1,213 components (27%)
📦 Total components: 4,528
```

### Why Some Components Failed

The scratch org was created with a basic configuration and is missing some features from your full dev/uat/prod orgs:

1. **Person Accounts** - Not enabled in scratch org
   - Fields like: PersonEmail, PersonBirthdate, PersonGenderIdentity, etc.
   - Affects: Account trigger, many Apex classes

2. **Custom Fields** - Some don't exist in scratch org schema
   - RazaoSocial__c, CNPJCPF__c, Email__c, InscricaoEstadual__c
   - Need to be created before dependent components deploy

3. **Managed Packages** - Components with namespaces can't be created
   - force__PartnerCloudChannelManagerPsg
   - sfdcInternalInt__sfdc_activityplatform

4. **Survey Feature** - Not enabled
   - Affects some flows

---

## How to Use Your Scratch Org

### ✅ What Works (3,315 components)

Most of your codebase deployed successfully:
- Core Apex classes (majority)
- Lightning Web Components
- Aura Components
- Custom Objects (most)
- Flows (most)
- Triggers (most)
- Layouts, Tabs, Custom Settings, etc.

### Development Workflow

#### 1. Work in Isolation
```bash
# Your scratch org is already set as default (🍁)
# Make changes directly in the scratch org via:
# - VS Code with Salesforce extensions
# - Direct org development (Setup UI)
# - Apex execute window

# Open scratch org
sf org open --target-org igor-scratch
```

#### 2. Pull Changes Back to Local
```bash
# After making changes in the scratch org UI
sf project retrieve start --target-org igor-scratch

# Review what changed
git status
git diff
```

#### 3. Deploy Specific Components
```bash
# Deploy a single class you're working on
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls --target-org igor-scratch

# Deploy a specific folder
sf project deploy start --source-path force-app/main/default/lwc/myComponent --target-org igor-scratch
```

#### 4. Test Your Changes
```bash
# Run specific test class
sf apex run test --class-names MyClassTest --target-org igor-scratch --result-format human

# Run all tests
sf apex run test --test-level RunLocalTests --target-org igor-scratch
```

#### 5. When Ready, Deploy to Dev Sandbox
```bash
# Switch to dev sandbox
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls --target-org dev

# Or commit to feature branch first
git add force-app/main/default/classes/MyClass.cls
git commit -m "feat: Add new feature"
git push origin feature/igor/my-feature

# Then deploy to dev
sf project deploy start --target-org dev --source-path force-app/main/default/classes/MyClass.cls
```

---

## Scratch Org Lifecycle

### Expiration
Your scratch org expires in **7 days** (2025-10-21). After that:
- All data and configurations are lost
- You'll need to create a new scratch org
- Code is safe in Git - no worries!

### Create a New Scratch Org

When your current one expires or you want a fresh start:

```bash
# Delete old scratch org (optional)
sf org delete scratch --target-org igor-scratch --no-prompt

# Create new scratch org with enhanced configuration
sf org create scratch --definition-file config/project-scratch-def.json --alias igor-scratch --set-default --duration-days 7 --wait 10

# Deploy core components (will have same partial deployment)
sf project deploy start --target-org igor-scratch

# Or deploy only what you need
sf project deploy start --source-path force-app/main/default/classes --target-org igor-scratch
sf project deploy start --source-path force-app/main/default/lwc --target-org igor-scratch
```

### Extend Expiration (if needed)

Can't extend an existing org, but you can create a new one for up to 30 days:

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias igor-scratch-30d --duration-days 30 --wait 10
```

---

## Best Practices with Scratch Orgs

### ✅ DO

- **Use for isolated feature development** - Test changes without affecting shared dev
- **Experiment freely** - It's temporary, break things and learn
- **Deploy frequently** - Test your deployment scripts
- **Commit often** - Source of truth is Git, not the scratch org
- **Test before deploying to dev** - Validate in scratch org first

### ❌ DON'T

- **Don't store important data** - It expires in 7 days!
- **Don't treat it as permanent** - Use dev sandbox for longer work
- **Don't rely on it matching prod 100%** - Some features/fields missing
- **Don't forget to pull changes** - Easy to lose work if not committed

---

## Workarounds for Failed Components

### If You Need Person Account Features

Person Accounts can't be enabled in Developer edition scratch orgs. Options:

1. **Use the shared dev sandbox** for Person Account work
2. **Request Enterprise edition scratch org** (requires org support)
3. **Mock the Person Account logic** in your scratch org tests

### If You Need Specific Custom Fields

Create them manually in the scratch org:

```bash
# Open scratch org
sf org open --target-org igor-scratch

# Go to Setup > Object Manager > Account > Fields & Relationships
# Create the missing fields manually
# Then deploy your dependent code
```

Or create a post-install script to set up these fields.

---

## Switching Between Orgs

### View All Orgs
```bash
sf org list
```

Output shows:
- 🌳 = DevHub (prod)
- 🍁 = Default org (currently igor-scratch)

### Change Default Org
```bash
# Set dev sandbox as default
sf config set target-org dev

# Set scratch org as default
sf config set target-org igor-scratch
```

### Always Specify Target Org (Recommended)
```bash
# Be explicit about which org you're deploying to
sf project deploy start --target-org igor-scratch
sf project deploy start --target-org dev
sf project deploy start --target-org uat
```

---

## Quick Reference

### Daily Commands

```bash
# Open your scratch org
sf org open --target-org igor-scratch

# Deploy your changes
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls --target-org igor-scratch

# Pull changes from scratch org
sf project retrieve start --target-org igor-scratch

# Run tests
sf apex run test --class-names MyClassTest --target-org igor-scratch

# Check org info
sf org display --target-org igor-scratch

# List all orgs
sf org list
```

### When to Use Which Org

| Task | Org to Use | Why |
|------|-----------|-----|
| New feature development | **igor-scratch** | Isolated, can break things |
| Fixing existing code | **igor-scratch** or **dev** | Scratch org preferred for safety |
| Testing with real data | **dev** | Scratch org has no data |
| Person Account work | **dev** | Scratch org doesn't support it |
| Team integration testing | **dev** | Shared environment |
| User acceptance testing | **uat** | Pre-production validation |
| Production hotfix | **Directly to prod** (with care!) | Emergency only |

---

## Troubleshooting

### Scratch Org Won't Open
```bash
# Check if it's still active
sf org list

# If expired, create new one
sf org create scratch --definition-file config/project-scratch-def.json --alias igor-scratch --set-default --duration-days 7 --wait 10
```

### Deployment Keeps Failing
```bash
# Check deployment status
sf project deploy report --use-most-recent --target-org igor-scratch

# See specific errors
# Fix errors one by one, or
# Deploy only specific components that work
```

### Lost Track of Changes
```bash
# See what's different between local and scratch org
sf project retrieve start --target-org igor-scratch
git status
git diff

# Discard scratch org changes and start over
git reset --hard HEAD
```

---

## Summary

Your scratch org (`igor-scratch`) is ready for development with **73% of your codebase deployed**. The missing 27% are mainly:
- Person Account specific features
- Some custom fields
- Managed package components

**Recommendation:**
Use the scratch org for most feature development, but switch to the shared `dev` sandbox when you need Person Account functionality or missing custom fields.

---

*Last Updated: 2025-10-14*
*Scratch Org Expiration: 2025-10-21*
