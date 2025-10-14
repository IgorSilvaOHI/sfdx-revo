# REVO Salesforce Development Environment - Setup Complete ✅

**Setup Date:** 2025-10-14
**Developer:** Igor Silva

---

## Environment Summary

### Salesforce Orgs Connected

| Environment | Alias | Username | Org ID | Branch Mapping |
|-------------|-------|----------|--------|----------------|
| **Production** | `prod` | igor.silva@ohi.pt.revo.prod | 00D09000009i6B0EAI | `main`, `release/prod` |
| **UAT** | `uat` | igor.silva@ohi.pt.uat | 00D89000003k1CIEAY | `release/uat` |
| **Dev** 🍁 | `dev` | igor.silva@ohi.pt.revodevsales | 00D89000002x9pKEAQ | `develop`, `feature/*` |

🍁 = Default org for development

---

## Git Repository

- **GitHub Repo:** https://github.com/IgorSilvaOHI/sfdx-revo
- **Authentication:** SSH (ed25519 key)
- **Local Path:** `C:\Users\igor.silva\salesforce\revo-dev`

### Branch Structure

```
main (production)
  ├── release/prod → Production deployments
  ├── release/uat → UAT testing
  └── develop → Active development (DEFAULT)
        ├── feature/* → New features
        ├── bugfix/* → Bug fixes
        └── hotfix/* → Critical fixes
```

**Current Branch:** `develop` ✓

---

## Retrieved Metadata

### Code Components
- **Apex Classes:** 467
- **Apex Triggers:** 8
- **Lightning Web Components:** 49
- **Aura Components:** 16

### Configuration
- **Custom Objects:** 95
- **Flows:** 91
- **Custom Labels:** Comprehensive set (196KB)
- **Global Value Sets:** 33

### Security
- **Roles:** 12
- **Public Groups:** 6 (Equipe Aviacao, Concierge, Comercial, Operacao, etc.)
- **Permission Sets:** Complete set
- **Sharing Rules:** All configured

### Automation
- **Assignment Rules:** Case, Lead
- **Workflow Rules:** Complete set
- **Quick Actions:** 100+

### Integration
- **Named Credentials:** REVOSite, cnpjws
- **Remote Site Settings:** Receita Federal, Flightradar24
- **Connected Apps:** WebSiteRevo

---

## Quick Start Commands

### Daily Development

```bash
# Start working
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Deploy to dev
sf project deploy start --target-org dev

# Run tests
sf apex run test --test-level RunLocalTests

# Commit and push
git add .
git commit -m "feat: Description of changes"
git push origin feature/my-feature
```

### Deploy to UAT

```bash
git checkout release/uat
git merge develop
sf project deploy start --target-org uat --test-level RunLocalTests
git push origin release/uat
```

### Deploy to Production

```bash
git checkout main
git merge release/uat
sf project deploy start --target-org prod --dry-run  # Validate first!
sf project deploy start --target-org prod --test-level RunLocalTests
git push origin main
git tag -a v1.0.0 -m "Production release"
git push origin v1.0.0
```

### Switch Between Orgs

```bash
# Deploy to specific org
sf project deploy start --target-org uat

# Open org in browser
sf org open --target-org prod

# Set default org
sf config set target-org dev
```

---

## Files & Documentation

### Key Files
- `WORKFLOW.md` - Complete development workflow guide
- `SALESFORCE_MCP_SETUP.md` - MCP integration setup
- `manifest/package.xml` - Original metadata manifest
- `manifest/package-enhanced.xml` - Enhanced metadata manifest
- `.gitignore` - Git ignore patterns
- `sfdx-project.json` - Salesforce DX configuration

### Folder Structure
```
revo-dev/
├── .git/                    # Git repository
├── .github/                 # GitHub workflows (future)
├── force-app/
│   └── main/default/        # All Salesforce metadata
│       ├── classes/         # Apex classes
│       ├── triggers/        # Apex triggers
│       ├── lwc/             # Lightning Web Components
│       ├── aura/            # Aura components
│       ├── flows/           # Flow definitions
│       ├── objects/         # Custom objects
│       ├── labels/          # Custom labels
│       ├── permissionsets/  # Permission sets
│       └── ...
├── manifest/                # Deployment manifests
├── scripts/                 # Helper scripts
└── config/                  # Scratch org definitions
```

---

## MCP Integration (Claude Code)

### Status
✅ **Active and Connected**

### Available MCP Tools
- `mcp__salesforce__list_all_orgs`
- `mcp__salesforce__run_soql_query`
- `mcp__salesforce__retrieve_metadata`
- `mcp__salesforce__deploy_metadata`
- `mcp__salesforce__open_org`
- `mcp__salesforce__create_scratch_org`
- `mcp__salesforce__assign_permission_set`
- And more...

### Configuration
- **MCP Config:** `C:\Users\igor.silva\.claude.json`
- **Enabled Toolsets:** orgs, metadata, data, users
- **Configured Orgs:** dev, uat, prod

---

## Best Practices Enabled

✅ Git version control with proper branching
✅ Separate environments (dev/uat/prod)
✅ SSH authentication for GitHub
✅ Metadata backup in version control
✅ MCP integration for AI-assisted development
✅ Comprehensive documentation
✅ .gitignore configured for Salesforce

---

## Next Steps

### Immediate
1. ✅ All orgs connected
2. ✅ Branches created and pushed
3. ✅ Documentation complete
4. ⏭️ **Start feature development**

### Short Term
- Set up GitHub branch protection rules
- Configure GitHub Actions for CI/CD
- Create pull request templates
- Set up code review process

### Long Term
- Implement automated testing
- Set up deployment monitoring
- Create deployment rollback procedures
- Document org-specific customizations

---

## Support & Resources

### Documentation
- **Workflow Guide:** `WORKFLOW.md`
- **Salesforce CLI Docs:** https://developer.salesforce.com/tools/salesforcecli
- **Git Branching:** https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows

### Commands Reference
```bash
# View all orgs
sf org list

# View config
sf config list

# View git branches
git branch -a

# View git status
git status
```

---

## Troubleshooting

### Org Connection Issues
```bash
# Re-authenticate
sf org login web --alias dev --instance-url https://test.salesforce.com

# Verify connection
sf org display --target-org dev
```

### Git Issues
```bash
# Check remote
git remote -v

# Pull latest
git pull origin develop

# Reset to remote
git reset --hard origin/develop
```

### MCP Issues
- Restart Claude Code completely
- Verify `~/.claude.json` exists
- Check org authorization: `sf org list`

---

**Environment Status: ✅ PRODUCTION READY**

*Last Updated: 2025-10-14*
*Setup performed with Claude Code*
