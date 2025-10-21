# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **📚 For comprehensive documentation**, see [README.md](README.md) - complete architecture overview, detailed object catalog, API documentation, and deployment guides.

## Project Overview

**REVO** is a Salesforce-based aviation charter and flight management platform that handles:
- Charter flights, shuttle services, and full cabin bookings (Revo Seats product line)
- Flight operations (missions, routes, aircraft, crew)
- Customer opportunity management with complex pricing and discounts
- Payment processing and gateway integrations
- Community portal for customer bookings

## Architecture

### Domain-Driven Design with fflib

This codebase follows **Enterprise Salesforce Architecture Patterns** using the fflib framework:

1. **Application Factory** (`Application.cls`) - Central registry for all factories
   - `Application.Selector` - Selector factory (query layer)
   - `Application.Service` - Service factory (business logic layer)
   - `Application.Domain` - Domain factory (trigger logic layer)
   - `Application.UnitOfWork` - Unit of work factory (DML operations)

2. **Layer Responsibilities**
   - **Selectors** (e.g., `VoosSelector`, `MissoesSelector`) - Query logic with field/security enforcement
   - **Services** (e.g., `MissoesService`, `OpportunityServiceImpl`) - Business logic orchestration
   - **Domains** (e.g., `Voos`, `Missoes`, `Opportunities`) - Trigger handlers with record-level logic
   - **Unit of Work** - Transaction boundary management and dependency ordering

3. **Key Patterns**
   - Interfaces for services (e.g., `IMissoesService`) with implementations (`MissoesServiceImpl`)
   - Constructor inner classes for domain instantiation
   - Service facade pattern (e.g., `MissoesService.criarMissoes()` delegates to implementation)

### Custom Trigger Framework

- Base class: `SObjectDomain.cls` (custom framework, not fflib's)
- Features: bypass mechanism, loop count protection, RecordType filtering
- All triggers delegate to domain classes (e.g., `VoosTrigger.trigger` → `Voos` domain)

### Key Business Objects

**Core Aviation Entities:**
- `Voo__c` (Flight) - Scheduled flights with crew, aircraft, and route assignments
- `Aeronave__c` (Aircraft) - Fleet management
- `Missao__c` (Mission) - Flight mission calculations and tracking
- `Trecho__c` (Leg) - Flight segments/legs
- `Aerovia__c` (Route) - Predefined air routes
- `MalhaVoo__c` (Flight Network) - Shuttle service schedules

**Customer & Sales:**
- `Opportunity` - Charter/shuttle bookings with custom fields for aviation pricing
- `OpportunityLineItem` - Flight segments, services, with pricing calculations
- `PassageiroOportunidade__c` (OpportunityPassenger) - Passengers linked to opportunities
- `ProdutoPassageiro__c` (PassengerProduct) - Passenger-specific services
- `CodigoPromocional__c` (PromoCode) - Promotional discounts
- `RegraPreco__c` / `RegraDesconto__c` - Pricing and discount rules

**Community Portal:**
- `RevoSite*` classes - REST APIs for customer portal
- Classes: `RevoSiteCheckout`, `RevoSiteCharterSearch`, `RevoSiteShuttleSearch`, `RevoSiteFullCabinSearch`

## Development Commands

### Testing
```bash
# Run all LWC tests
npm run test:unit

# Watch mode
npm run test:unit:watch

# Coverage report
npm run test:unit:coverage

# Run specific test
sfdx-lwc-jest --testPathPattern=componentName

# Run Apex tests locally
sf apex run test --test-level RunLocalTests --result-format human

# Run specific Apex test class
sf apex run test --class-names MyTestClass --result-format human
```

### Code Quality
```bash
# Lint JavaScript (Aura/LWC)
npm run lint

# Format code
npm run prettier

# Verify formatting
npm run prettier:verify
```

### Salesforce Operations
```bash
# Deploy to default org
sf project deploy start

# Deploy specific files
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls

# Retrieve from org
sf project retrieve start --source-path force-app/main/default/classes/

# Run anonymous Apex
sf apex run --file scripts/apex/myScript.apex
```

## Git Workflow & Branching

This project uses a **strict three-environment promotion workflow**:

**Branch → Org Mapping:**
- `main` → Production org (protected)
- `release/uat` → UAT Sandbox (protected)
- `develop` → Dev Sandbox (default, shared by 4 developers)
- `feature/*` → Developer personal scratch orgs or dev sandbox

**Important Rules:**
1. **NEVER commit directly to `main`, `release/uat`, or `develop`**
2. Always create feature branches: `feature/developer-name/description`
3. Multiple developers share the dev sandbox - retrieve before deploying
4. Use scratch orgs for isolated feature development
5. Follow conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`

**See detailed workflows:**
- `WORKFLOW.md` - Complete promotion workflow (dev → uat → prod)
- `MULTI_DEV_WORKFLOW.md` - Multi-developer safety guide for shared sandbox
- `SCRATCH_ORG_GUIDE.md` - Personal scratch org development

## Lightning Web Components

### Key Reusable Components
- `lookup` / `lookupItem` - Custom lookup component
- `formulaBuilder` - Formula creation UI
- `customIcons` - Custom SVG icon library
- `buttonActionNavigation` - Programmatic navigation wrapper
- `utils` - Shared utility functions

### Aviation-Specific LWCs
- `malhaVooCard` - Flight network card display
- `gerenciarPassageiros` - Passenger management interface
- `vincularPassageiroVooModal` - Link passengers to flights
- `configurarVoo` - Flight configuration UI
- `listaConfiguracaoVoo` - Flight configuration list

### Testing LWC
- Framework: `@salesforce/sfdx-lwc-jest`
- Test files: `*.test.js` alongside component
- Mock utilities available in `force-app/test/jest-mocks/`

## Static Resources

- **leaflet** - Map library for location/route visualization
- **xlsx** - Excel export functionality
- **Medals/Stars/Shields** - Gamification assets for community
- **LogoComunidade/backgroundBannerComunidade** - Branding assets

## Development Best Practices

### Apex Development
1. **Always use Application factories** - Never instantiate selectors/services directly
2. **Use Unit of Work** - Register all DML operations with `fflib_ISObjectUnitOfWork`
3. **Selector usage**: `(VoosSelector) Application.Selector.newInstance(Voo__c.SObjectType)`
4. **Service usage**: `(IMissoesService) Application.Service.newInstance(IMissoesService.class)`
5. **Respect transaction boundaries** - Services should handle UoW commit
6. **Test data factory**: Use `TestUtil2.cls` for test data creation

### Code Organization
- Interfaces prefixed with `I` (e.g., `IVoosService`)
- Service implementations suffixed with `Impl` (e.g., `VoosServiceImpl`)
- Domain classes are plural (e.g., `Voos`, `Missoes`)
- Selector classes suffixed with `Selector` (e.g., `VoosSelector`)

### Deployment Safety
- **Before UAT**: Always validate with `--dry-run`
- **Before Production**: Always validate first, never deploy directly
- **Run tests**: Use `--test-level RunLocalTests` for production deployments
- **Shared Dev Sandbox**: Retrieve before deploy to avoid overwriting others' work

## Key Files

- `sfdx-project.json` - Salesforce DX project configuration (API v64.0)
- `Application.cls` - Central factory registry (CRITICAL - all dependencies here)
- `SObjectDomain.cls` - Custom trigger framework base class
- `.forceignore` - Files excluded from deploy/retrieve
- `manifest/package.xml` - Deployment package manifest
- `config/project-scratch-def.json` - Scratch org definition

## MCP Integration

This project is configured with Salesforce MCP tools via `.mcp.json`:
- Use MCP tools for org operations, metadata deploy/retrieve, SOQL queries
- MCP tools work with org aliases: `dev`, `uat`, `prod`

## Important Notes

- **Shared Dev Sandbox**: 4 developers share the dev org - coordinate deployments
- **API Version**: Project uses API version 64.0
- **Community Portal**: External site with REST endpoints (`RevoSite*` classes)
- **Complex Pricing**: Opportunity line items have custom pricing logic based on flight time, aircraft model, routes, and promotional rules
- **Portuguese Labels**: Many custom labels and field names are in Portuguese (Brazilian market)
- **RecordTypes**: Multiple opportunity record types (`Oportunidade`, `RevoSeats`) with different logic
- **Payment Integration**: Gateway integrations via `Pagamento__c` and `TransacaoGateway__c`
