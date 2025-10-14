# Salesforce Development Workflow - REVO

## Branch Strategy

```
main (production - protected)
  │
  ├── release/uat (UAT testing)
  │     │
  │     └── develop (active development - default)
  │           │
  │           ├── feature/feature-name
  │           ├── bugfix/bug-description
  │           └── hotfix/critical-fix
```

### Branch Mapping to Orgs

| Branch | Salesforce Org | Purpose | Protected |
|--------|---------------|---------|-----------|
| `main` | **Production** | Live customer data | ✅ Yes |
| `release/uat` | **UAT Sandbox** | User acceptance testing | ✅ Yes |
| `develop` | **Dev Sandbox** (mySandbox) | Integration & testing | ⚠️ Recommended |
| `feature/*` | Dev Sandbox or Personal Sandbox | Feature development | ❌ No |

---

## Daily Development Workflow

### Step 1: Start a New Feature

```bash
# Make sure you're on develop with latest changes
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/my-feature-name

# Set your dev org as default
sf config set target-org dev
```

### Step 2: Develop & Test Locally

```bash
# Make changes to your code in VS Code or IDE
# When ready, retrieve any changes from dev org
sf project retrieve start --source-path force-app/main/default/classes/MyClass.cls

# Or retrieve everything
sf project retrieve start --manifest manifest/package.xml

# Run local tests
sf apex run test --test-level RunLocalTests --result-format human
```

### Step 3: Commit Your Changes

```bash
# Add files
git add .

# Commit with descriptive message
git commit -m "feat: Add new feature XYZ

- Added MyNewClass for feature logic
- Updated OpportunityTrigger to call new class
- Added test coverage (90%)

Fixes #123"

# Push to GitHub
git push origin feature/my-feature-name
```

### Step 4: Merge to Develop

```bash
# Switch to develop
git checkout develop
git pull origin develop

# Merge your feature
git merge feature/my-feature-name

# Push to develop
git push origin develop

# Deploy to DEV sandbox
sf project deploy start --target-org dev
```

---

## Promotion Workflow (Dev → UAT → Prod)

### 🟢 Deploy to UAT

```bash
# 1. Create release branch if it doesn't exist
git checkout -b release/uat
git push -u origin release/uat

# 2. Merge develop into UAT
git checkout release/uat
git pull origin release/uat
git merge develop

# 3. Deploy to UAT org
sf project deploy start --target-org uat --dry-run  # Validate first
sf project deploy start --target-org uat --test-level RunLocalTests

# 4. If successful, push to GitHub
git push origin release/uat

# 5. Tag the release
git tag -a v1.0.0-uat -m "Release to UAT - Sprint 1"
git push origin v1.0.0-uat
```

### 🔴 Deploy to Production

```bash
# 1. Merge UAT to main
git checkout main
git pull origin main
git merge release/uat

# 2. VALIDATE in production (DO NOT deploy yet)
sf project deploy start --target-org prod --dry-run --test-level RunLocalTests

# 3. Review validation results carefully

# 4. If validation passes, deploy for real
sf project deploy start --target-org prod --test-level RunLocalTests

# 5. Push and tag
git push origin main
git tag -a v1.0.0 -m "Production Release - Sprint 1"
git push origin v1.0.0
```

---

## Org Management

### Connect All Your Orgs (One-time Setup)

```bash
# DEV Sandbox (your current mySandbox)
sf org login web --alias dev --instance-url https://test.salesforce.com

# UAT Sandbox
sf org login web --alias uat --instance-url https://test.salesforce.com

# Production
sf org login web --alias prod --instance-url https://login.salesforce.com

# Set develop branch to use dev org by default
sf config set target-org dev
```

### Switch Between Orgs

```bash
# Deploy to specific org
sf project deploy start --target-org uat

# Retrieve from specific org
sf project retrieve start --target-org prod --manifest manifest/package.xml

# Open org in browser
sf org open --target-org dev

# Check which org is default
sf config get target-org

# Change default org
sf config set target-org uat
```

---

## Best Practices

### ✅ DO

- **Always work on feature branches** - Never commit directly to `develop`, `release/uat`, or `main`
- **Pull before you push** - Always `git pull` before starting work
- **Write meaningful commit messages** - Follow conventional commits (feat:, fix:, refactor:, etc.)
- **Test before merging** - Run Apex tests locally before merging to develop
- **Use dry-run for production** - Always validate before deploying to prod
- **Tag releases** - Use semantic versioning (v1.0.0, v1.1.0, etc.)
- **Document deployments** - Keep deployment notes in commit messages

### ❌ DON'T

- **Don't commit directly to main** - Always go through UAT first
- **Don't skip tests** - Never deploy without running tests
- **Don't deploy on Fridays** (to prod) - Give yourself time to fix issues
- **Don't mix features** - One feature per branch
- **Don't commit credentials** - Use `.gitignore` and environment variables

---

## Common Scenarios

### Scenario 1: Hotfix for Production

```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug-fix

# 2. Make the fix and test
# ... make changes ...
git add .
git commit -m "hotfix: Fix critical bug in payment processing"

# 3. Deploy to production immediately
sf project deploy start --target-org prod --test-level RunLocalTests

# 4. Merge back to main and develop
git checkout main
git merge hotfix/critical-bug-fix
git push origin main

git checkout develop
git merge hotfix/critical-bug-fix
git push origin develop

# 5. Also merge to UAT to keep in sync
git checkout release/uat
git merge hotfix/critical-bug-fix
git push origin release/uat
```

### Scenario 2: Retrieve Changes Made Directly in Org

```bash
# Sometimes admins make changes directly in the org
# Retrieve them and commit to version control

# 1. Retrieve from org
sf project retrieve start --target-org dev --manifest manifest/package.xml

# 2. Review changes
git status
git diff

# 3. Commit the changes
git add .
git commit -m "chore: Sync metadata changes from dev org"
git push origin develop
```

### Scenario 3: Rollback a Bad Deployment

```bash
# If something goes wrong in production

# Option A: Revert the commit
git revert HEAD
git push origin main
sf project deploy start --target-org prod --test-level RunLocalTests

# Option B: Re-deploy previous version
git checkout <previous-commit-hash>
sf project deploy start --target-org prod --test-level RunLocalTests
```

---

## Commit Message Convention

Use conventional commits for better tracking:

```
feat: Add new feature
fix: Bug fix
refactor: Code refactoring
test: Add or update tests
docs: Documentation changes
chore: Maintenance tasks
perf: Performance improvements
style: Code style changes
```

**Examples:**
```bash
git commit -m "feat: Add discount calculation for opportunities"
git commit -m "fix: Resolve null pointer in VoosTrigger"
git commit -m "refactor: Optimize SOQL queries in AeronavesSelector"
git commit -m "test: Add test coverage for CheckoutOportunidade"
```

---

## Quick Reference

### Daily Commands

```bash
# Start your day
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# End your day
git add .
git commit -m "feat: Work in progress on feature X"
git push origin feature/new-feature

# Deploy to dev
sf project deploy start --target-org dev

# Run tests
sf apex run test --test-level RunLocalTests
```

### Emergency Commands

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard HEAD

# See what changed
git status
git diff

# View commit history
git log --oneline --graph
```

---

## Deployment Checklist

### Before ANY Deployment

- [ ] All tests pass locally
- [ ] Code reviewed (if team collaboration)
- [ ] Commit messages are clear
- [ ] Branch is up to date with target

### Before UAT Deployment

- [ ] Feature tested in dev sandbox
- [ ] No unrelated changes included
- [ ] Deployment validated (`--dry-run`)

### Before Production Deployment

- [ ] UAT testing completed and approved
- [ ] Validation passed in production
- [ ] Deployment window scheduled
- [ ] Rollback plan ready
- [ ] Stakeholders notified

---

*Last Updated: 2025-10-14*
*Maintained by: Development Team*
