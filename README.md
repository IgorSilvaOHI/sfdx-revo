# REVO - Aviation Charter & Flight Management Platform

## 🚁 Executive Summary

**REVO** is a comprehensive Salesforce-based aviation charter and flight management platform designed for helicopter and aircraft operations in Brazil. The system manages the complete lifecycle of charter flights, shuttle services (RevoSeats), full cabin bookings, flight operations, crew management, and customer relationships through an integrated community portal.

### Key Business Capabilities
- **Charter Flight Management** - Ad-hoc flight bookings with complex pricing rules
- **Shuttle Services (RevoSeats)** - Scheduled flight network with seat-by-seat bookings
- **Full Cabin Bookings** - Complete aircraft rental for groups
- **Flight Operations** - Mission planning, route management, crew assignments
- **Fleet Management** - Aircraft tracking, maintenance, availability
- **Payment Processing** - Multi-gateway payment integration with promotional codes
- **Community Portal** - Customer self-service booking and management

---

## 📊 Technical Architecture Overview

### Technology Stack
- **Platform**: Salesforce (API Version 64.0)
- **Architecture Pattern**: Enterprise fflib-apex-common (Separation of Concerns)
- **Apex Classes**: 467 classes
- **Custom Objects**: 96 objects (64 custom objects + 32 metadata types)
- **LWC Components**: 50 Lightning Web Components
- **Aura Components**: 15 Aura components (legacy)
- **Flows**: 91 flows (Screen Flows, Autolaunched, Record-Triggered)
- **Triggers**: 8 triggers (all delegated to Domain layer)

### Architecture Pattern: fflib Enterprise Application Pattern

The codebase follows **Separation of Concerns** using the fflib framework:

```
┌─────────────────────────────────────────────────────────────┐
│                    Application.cls                          │
│              (Central Factory Registry)                     │
│  ┌──────────────┬──────────────┬──────────────┬──────────┐ │
│  │   Selector   │   Service    │    Domain    │ UnitOfWork│ │
│  │   Factory    │   Factory    │   Factory    │  Factory  │ │
│  └──────────────┴──────────────┴──────────────┴──────────┘ │
└─────────────────────────────────────────────────────────────┘
           │              │              │              │
           ▼              ▼              ▼              ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ Selectors│   │ Services │   │ Domains  │   │   UoW    │
    │ (Query)  │   │(Business)│   │(Triggers)│   │  (DML)   │
    └──────────┘   └──────────┘   └──────────┘   └──────────┘
```

#### Layer Breakdown

**1. Selector Layer (Data Access)**
- **Purpose**: Query logic with field-level security enforcement
- **Count**: 30+ selector classes
- **Key Classes**: `VoosSelector`, `MissoesSelector`, `OpportunitySelector`, `AeronavesSelector`
- **Usage Pattern**:
  ```apex
  VoosSelector selector = (VoosSelector) Application.Selector.newInstance(Voo__c.SObjectType);
  List<Voo__c> voos = selector.selectById(vooIds);
  ```

**2. Service Layer (Business Logic)**
- **Purpose**: Orchestrate business processes, coordinate multiple domains
- **Count**: 11 service interfaces + implementations
- **Key Services**:
  - `MissoesService` - Flight mission calculations
  - `OpportunityService` - Booking and pricing logic
  - `VoosService` - Flight lifecycle management
  - `PagamentosService` - Payment processing
  - `PassageirosService` - Passenger management
- **Usage Pattern**:
  ```apex
  IMissoesService service = (IMissoesService) Application.Service.newInstance(IMissoesService.class);
  service.criarMissoes(uow, calculoMap);
  ```

**3. Domain Layer (Trigger Logic)**
- **Purpose**: Record-level validation and business rules
- **Count**: 13 domain classes
- **Key Domains**: `Voos`, `Missoes`, `Accounts`, `Passageiros`, `Pagamentos`
- **Custom Framework**: Uses `SObjectDomain.cls` (custom, not fflib's)
  - Bypass mechanism for integration scenarios
  - Loop count protection
  - RecordType-based filtering
- **Trigger Delegation**: All triggers delegate to domains
  ```apex
  // VoosTrigger.trigger
  fflib_SObjectDomain.triggerHandler(Voos.class);
  ```

**4. Unit of Work (Transaction Management)**
- **Purpose**: Manage DML operations with dependency ordering
- **Pattern**: Bulkified DML with relationship resolution
- **Dependency Order** (Application.cls:4-58):
  ```
  User → Account → CodigoPromocional → Local → Aerovia → Product2
  → Aeronave → Missao → Voo → Trecho → Opportunity → OpportunityLineItem
  → Pagamento → PassageiroOportunidade → ProdutoPassageiro
  ```

---

## 🗂️ Domain Model & Core Objects

### Aviation Operations

#### **Voo__c (Flight)** 🛩️
- **Description**: Complete flight from origin through return
- **Key Fields**:
  - `DataVoo__c` - Flight date/time
  - `Status__c` - Flight status (Rascunho, Reservado, Confirmado, Executado, Cancelado, Faturado)
  - `Prefixo__c` - Aircraft assignment
  - `Cliente__c` - Customer account
  - `Tipo__c` - Flight type (Charter, Shuttle, Training, etc.)
  - `RotaAbreviada__c` - Route summary
- **Record Types**: Charter, Shuttle, Training, Maintenance
- **Statuses**:
  - Rascunho (Draft) → Pré-reservado (Pre-reserved) → Reservado (Reserved)
  → Confirmado (Confirmed) → Rota (En Route) → Executado (Executed)
  → Em Faturamento (Invoicing) → Faturado (Invoiced) → Cancelado (Cancelled)
- **Related Objects**: Trecho__c (legs), PassageiroVoo__c (passengers), Missao__c (mission)
- **Automation**: Complex trigger logic in `Voos.cls` domain class
- **Integration**: Integrated with external flight management systems

#### **Trecho__c (Flight Leg)** ✈️
- **Description**: Individual flight segments within a flight
- **Key Fields**:
  - `Voo__c` - Parent flight
  - `Origem__c`, `Destino__c` - Origin/destination locations
  - `HorarioDecolagem__c`, `HorarioPousoReal__c` - Departure/arrival times
  - `OrdemExecucao__c` - Execution order
  - `TipoTrecho__c` - Leg type (Missao, Translado Ida, Translado Retorno)
  - `DistanciaKm__c` - Distance in km
- **Business Rules**:
  - First leg defines flight start location
  - Last leg defines return location
  - Translado (positioning) legs calculated automatically

#### **Missao__c (Mission)** 🎯
- **Description**: Flight mission calculations (time, fuel, costs)
- **Key Fields**:
  - `Voo__c` - Associated flight
  - `TempoMissao__c` - Total mission time (minutes)
  - `TempoTransladoIda__c`, `TempoTransladoRetorno__c` - Positioning time
  - `TempoPrevisto__c` - Estimated time
  - `ValorMissao__c` - Mission value
- **Calculation Logic**: Service `MissoesService` handles complex time/cost calculations
- **Usage**: Created automatically when flight is confirmed

#### **Aeronave__c (Aircraft)** 🚁
- **Description**: Fleet aircraft/helicopter registry
- **Key Fields**:
  - `Prefixo__c` - Aircraft registration (e.g., PT-HXX)
  - `Modelo__c` - Aircraft model
  - `CapacidadePassageiros__c` - Passenger capacity
  - `Status__c` - Aircraft status (Disponível, Manutenção, Inoperante)
  - `BasePrincipal__c` - Home base location
- **Related Objects**:
  - `IndisponibilidadeAeronave__c` - Maintenance/unavailability periods
  - `AeronaveDisponivel__c` - Availability cache for scheduling
  - `BackupAeronave__c` - Backup aircraft assignments

#### **Aerovia__c (Route)** 🗺️
- **Description**: Predefined air routes between locations
- **Key Fields**:
  - `Origem__c`, `Destino__c` - Route endpoints
  - `DistanciaKm__c` - Distance
  - `TempoPrevisto__c` - Estimated flight time
  - `TaxaAterissagem__c`, `TaxaPouso__c` - Landing fees
- **Purpose**: Pre-calculated route data for pricing and mission planning

#### **Local__c (Location)** 📍
- **Description**: Airports, heliports, helipads
- **Key Fields**:
  - `Codigo__c` - Location code (ICAO/internal)
  - `Tipo__c` - Type (Aeroporto, Heliponto, Heliporto)
  - `Latitude__c`, `Longitude__c` - GPS coordinates
  - `Estado__c`, `Cidade__c` - State/city
  - `TaxaPouso__c` - Landing fee
- **Features**: Map visualization using Leaflet.js

#### **MalhaVoo__c (Flight Network)** 🕸️
- **Description**: Scheduled shuttle flight network (RevoSeats)
- **Key Fields**:
  - `Origem__c`, `Destino__c` - Route
  - `DiasSemana__c` - Days of week (Mon-Sun)
  - `HorarioPrevisao__c` - Scheduled time
  - `ModeloAeronave__c` - Aircraft model
  - `QuantidadeAssentos__c` - Available seats
  - `PrecoBase__c` - Base price per seat
  - `Ativa__c` - Active/inactive
- **Purpose**: Shuttle scheduling engine for RevoSeats product
- **Related**: `Horarioextradamalha__c` (extra schedule slots), `PrioridadeMalha__c` (priority rules)

### Customer & Sales

#### **Account (Customer)** 👤
- **RecordTypes**:
  - Cliente (Customer)
  - Parceiro (Partner/Broker)
  - Fornecedor (Supplier)
- **Key Fields**:
  - `TipoPessoa__c` - Person type (PF/PJ - Individual/Corporate)
  - `CNPJ__c`, `CPF__c` - Tax IDs
  - `ClassificacaoCliente__c` - Customer classification
- **Related**: Contact, Lead, UsuarioSite__c (portal user)

#### **Opportunity** 💼
- **RecordTypes**:
  - **Oportunidade** - Charter flights
  - **RevoSeats** - Shuttle seat bookings
- **Key Fields**:
  - `CodigoReserva__c` - Booking code (6-char)
  - `TipoReserva__c` - Booking type (Charter, ShuttleSeat, FullCabin)
  - `Voo__c` - Associated flight
  - `PrevisaoVoo__c` - Flight date/time
  - `QuantidadePassageiros__c` - Number of passengers
  - `ValorTotal__c` - Total value
  - `ValorComDesconto__c` - Discounted value
  - `DataBloqueioPreco__c` - Price lock expiration
  - `StatusPagamento__c` - Payment status
- **Stages**: Qualification → Proposal → Negotiation → Closed Won/Lost
- **Automation**: Complex pricing logic in `OpportunityServiceImpl`

#### **OpportunityLineItem (Line Item)** 📋
- **Purpose**: Flight segments and services within booking
- **Types**:
  - Flight legs (priced by flight time)
  - Additional services (catering, ground transport)
- **Pricing**: Dynamic pricing based on aircraft model, route, time, promotional rules

#### **PassageiroOportunidade__c (Opportunity Passenger)** 👥
- **Description**: Passengers linked to opportunities/bookings
- **Key Fields**:
  - `Oportunidade__c` - Parent opportunity
  - `Passageiro__c` - Passenger record
  - `Nome__c`, `Documento__c`, `DataNascimento__c` - Passenger info
  - `Peso__c` - Weight (for load calculations)
- **Purpose**: Passenger manifest for flight bookings

#### **ProdutoPassageiro__c (Passenger Product)** 🛍️
- **Description**: Services/add-ons per passenger
- **Examples**: Meals, insurance, ground transportation
- **Key Fields**:
  - `PassageiroOportunidade__c` - Passenger
  - `Produto__c` - Product/service
  - `Quantidade__c` - Quantity
  - `Valor__c` - Price

#### **Passageiro__c (Passenger Master)** 🧳
- **Description**: Master passenger registry
- **Key Fields**:
  - `Nome__c` - Full name
  - `Documento__c` - Document number (CPF/RG/Passport)
  - `DataNascimento__c` - Birth date
  - `Peso__c` - Weight
  - `Telefone__c`, `Email__c` - Contact info
- **Purpose**: Reusable passenger data across bookings

#### **PassageiroVoo__c (Flight Passenger)** 🎫
- **Description**: Passengers assigned to specific flights (junction)
- **Key Fields**:
  - `Voo__c` - Flight
  - `Passageiro__c` - Passenger
  - `Status__c` - Check-in status
  - `Assento__c` - Seat number

### Pricing & Promotions

#### **RegraPreco__c (Pricing Rule)** 💰
- **Description**: Dynamic pricing rules
- **Criteria**: Aircraft model, route, time of day, day of week, season
- **Calculation**: Complex formula-based pricing

#### **RegraDesconto__c (Discount Rule)** 🏷️
- **Description**: Discount rules with conditions
- **Types**: Percentage, fixed amount, tiered discounts
- **Related**: `FaixaRegraDesconto__c` (discount tiers)

#### **CodigoPromocional__c (Promo Code)** 🎟️
- **Description**: Promotional discount codes
- **Key Fields**:
  - `Codigo__c` - Promo code (unique)
  - `TipoDesconto__c` - Discount type (%, Fixed)
  - `ValorDesconto__c` - Discount value
  - `DataInicio__c`, `DataFim__c` - Validity period
  - `QuantidadeUsos__c`, `QuantidadeUsada__c` - Usage limits
  - `Ativo__c` - Active status
- **Related**: `ItemPromocao__c` (applicable products)

#### **ConfiguracaoPacote__c (Package Configuration)** 📦
- **Description**: Service bundles/packages
- **Purpose**: Pre-configured service packages for different customer segments

### Payment Processing

#### **Pagamento__c (Payment)** 💳
- **Description**: Payment records for opportunities
- **Key Fields**:
  - `Oportunidade__c` - Associated opportunity
  - `Valor__c` - Payment amount
  - `Status__c` - Payment status (Pendente, Aprovado, Cancelado, Estornado)
  - `FormaPagamento__c` - Payment method (Credit Card, Debit, PIX, Boleto)
  - `DataPagamento__c` - Payment date
  - `GatewayPagamento__c` - Gateway used
- **Statuses**: Pendente → Processando → Aprovado/Recusado/Cancelado/Estornado

#### **TransacaoGateway__c (Gateway Transaction)** 🔐
- **Description**: Payment gateway transaction logs
- **Key Fields**:
  - `Pagamento__c` - Parent payment
  - `Gateway__c` - Gateway name
  - `TransacaoId__c` - Gateway transaction ID
  - `Status__c` - Transaction status
  - `Retorno__c` - Gateway response (JSON)
- **Purpose**: Audit trail and reconciliation

#### **ConfiguracaoPagamento__c (Payment Config)** ⚙️
- **Description**: Payment gateway configurations
- **Storage**: Gateway credentials, endpoints, merchant IDs

### Operational Objects

#### **Tripulacao__c (Crew)** 👨‍✈️
- **Description**: Crew assignments for flights
- **Roles**: Pilot, Co-pilot, Flight Attendant

#### **Carga__c (Cargo)** 📦
- **Description**: Cargo shipments
- **Related**: `CargaVoo__c` (cargo on flights)

#### **LogVoo__c (Flight Log)** 📝
- **Description**: Flight operation logs
- **Purpose**: Audit trail of flight events

#### **Briefing__c (Flight Briefing)** 📋
- **Description**: Pre-flight briefing documents
- **Content**: Weather, NOTAMs, flight plan

#### **Meteograma__c (Weather)** 🌤️
- **Description**: Weather data for flight planning

### Configuration & Metadata

#### **ConfiguracaoTempo__c (Time Configuration)** ⏱️
- **Type**: Custom Settings (Org defaults)
- **Purpose**: Timeouts, reservation expiry times
- **Key Fields**:
  - `MinutosBloqueioReservarVoo__c` - Reservation hold time
  - `MinutosBloqueioSelecaoVoo__c` - Selection timeout

#### **ConfiguracoesGerais__c (General Settings)** 🔧
- **Type**: Custom Settings
- **Purpose**: Global platform settings

#### **Integracao__mdt (Integration Metadata)** 🔌
- **Type**: Custom Metadata Type
- **Purpose**: External integration endpoints and configurations

---

## 🎨 User Interface Layer

### Lightning Web Components (50 components)

#### **Aviation-Specific LWCs**
- `configurarVoo` - Flight configuration interface
- `listaConfiguracaoVoo` - Flight configuration list
- `malhaVooCard` - Shuttle flight network card display
- `malhaVooDatatable` - Flight network data table
- `pesquisaVooDisponivel` - Available flight search
- `voosAndamentoMap` - In-progress flights map (Leaflet.js)
- `aeronaveTimeline` - Aircraft timeline visualization
- `inputLocalVoo` - Location picker for flights

#### **Passenger Management**
- `gerenciarPassageiros` - Passenger management interface
- `listaPassageiros` - Passenger list component
- `modalNovoPassageiro` - New passenger modal
- `vincularPassageiroVooModal` - Link passenger to flight modal
- `vincularPassageiroVooDatatable` - Passenger-flight linking table
- `vincularServicoPassageiroDatatable` - Passenger services table

#### **Cargo Management**
- `cargasTrecho` - Cargo by flight leg
- `listaCargas` - Cargo list
- `listaCargasVoo` - Flight cargo list
- `headerListaCargas` - Cargo list header
- `linhaListaCargas` - Cargo list row

#### **Reusable Components**
- `lookup` / `lookupItem` / `lookupAction` - Custom lookup component (3-tier)
- `formulaBuilder` - Formula creation UI
- `customIcons` - Custom SVG icon library
- `buttonActionNavigation` - Navigation wrapper with modal support
- `modalPopup` - Generic modal component
- `filtro` - Generic filter component
- `utils` - Shared utility functions (date, currency, validation)
- `getRecord` / `getUserInfo` - Data fetching utilities

#### **Opportunity Management**
- `criarOportunidadeModal` - Create opportunity modal
- `criarOportunidadeFlowLauncher` - Flow launcher for opp creation

#### **File & Document**
- `fileUploader` - File upload component
- `embedEnvelope` - DocuSign envelope embedding
- `excelImporterDataPreview` - Excel import preview

### Aura Components (15 components - Legacy)
- `CriacaoOportunidadeRapida` - Quick opportunity creation
- `CriacaoOportunidadeRevoSeats` - RevoSeats booking
- `ContainerGerenciarVoo` - Flight management container
- `addHorarioMalha` - Add shuttle schedule
- `Case360HighlightCard` - Case management
- Utility: `flowRefreshView`, `refreshAction`, `redirectToRecord`
- Community: `loginForm`, `selfRegister`, `forgotPassword`

### Static Resources
- **leaflet** - Leaflet.js library (map visualization)
- **xlsx** - SheetJS library (Excel export)
- **Medals/Stars/Shields** - Gamification assets
- **LogoComunidade/backgroundBannerComunidade** - Community branding

---

## 🌐 Community Portal & APIs

### REST API Endpoints (RevoSite)

All REST endpoints use base URL pattern: `/services/apexrest/revosite/v1/`

#### **RevoSiteCheckout** (`/checkout`)
- **Purpose**: Handle booking checkout process
- **Methods**: POST
- **Flow**:
  1. Price validation (resume without confirm)
  2. Confirmation with payment
  3. Creates Opportunity + Flight + Passengers + Payments
- **Security**: Validates user session, price lock expiration
- **Transaction**: Uses savepoints for rollback on errors

#### **RevoSiteCharterSearch** (`/charter/search`)
- **Purpose**: Search available charter flights
- **Methods**: POST
- **Returns**: Available aircraft, pricing, routes

#### **RevoSiteShuttleSearch** (`/shuttle/search`)
- **Purpose**: Search shuttle flights (RevoSeats)
- **Methods**: POST
- **Returns**: Available shuttle flights with seat availability

#### **RevoSiteFullCabinSearch** (`/fullcabin/search`)
- **Purpose**: Search full cabin bookings
- **Methods**: POST
- **Returns**: Available aircraft for full cabin rental

#### **RevoSitePaymentView** (`/payment/view`)
- **Purpose**: View payment details
- **Methods**: GET
- **Returns**: Payment status, transaction history

#### **RevoSiteTransaction** (`/transaction`)
- **Purpose**: Process payment transactions
- **Methods**: POST
- **Integration**: Payment gateway processing

#### **RevoSitePaymentPromotion** (`/payment/promotion`)
- **Purpose**: Apply promotional codes
- **Methods**: POST
- **Validation**: Code validity, usage limits, expiration

#### **RevoSiteUserApi** (`/user`)
- **Purpose**: User management (registration, login, profile)
- **Methods**: GET, POST, PUT
- **Related Object**: `UsuarioSite__c`

#### **RevoSiteCheckoutCancel** (`/checkout/cancel`)
- **Purpose**: Cancel pending checkout/reservation
- **Methods**: POST
- **Action**: Releases flight hold, cancels payments

### Community Portal Features
- Customer self-service booking
- Flight search (Charter, Shuttle, Full Cabin)
- Passenger management
- Payment processing
- Booking history
- Profile management

---

## 🔧 Development Practices

### Code Organization Standards

#### Naming Conventions
- **Interfaces**: Prefixed with `I` (e.g., `IVoosService`, `IMissoesService`)
- **Service Implementations**: Suffixed with `Impl` (e.g., `VoosServiceImpl`, `OpportunityServiceImpl`)
- **Domain Classes**: Plural nouns (e.g., `Voos`, `Missoes`, `Accounts`)
- **Selector Classes**: Suffixed with `Selector` (e.g., `VoosSelector`, `AeronavesSelector`)
- **Test Classes**: Suffixed with `Test` (e.g., `VoosTest`, `MissoesServiceTest`)

#### Application Factory Usage

**Always use Application factories** - Never instantiate selectors/services directly:

```apex
// ✅ CORRECT
VoosSelector selector = (VoosSelector) Application.Selector.newInstance(Voo__c.SObjectType);
IMissoesService service = (IMissoesService) Application.Service.newInstance(IMissoesService.class);

// ❌ WRONG
VoosSelector selector = new VoosSelector();
MissoesServiceImpl service = new MissoesServiceImpl();
```

#### Unit of Work Pattern

**Always use Unit of Work for DML operations**:

```apex
fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

// Register operations (no DML yet)
uow.registerNew(newVoo);
uow.registerNew(trechos, Trecho__c.Voo__c, newVoo);
uow.registerDirty(existingAccount);
uow.registerDeleted(oldMissao);

// Commit all operations in correct dependency order
uow.commitWork();
```

#### Domain Class Structure

```apex
public class Voos extends fflib_SObjectDomain implements IVoos {

    // Constants
    public static final String RASCUNHO = 'Rascunho';
    public static final String CONFIRMADO = 'Confirmado';

    // Constructor
    public Voos(List<Voo__c> records) {
        super(records);
        Configuration.disableTriggerCRUDSecurity();
    }

    // Inner class for factory instantiation
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Voos(sObjectList);
        }
    }

    // Trigger event handlers
    public override void onBeforeInsert() { }
    public override void onAfterInsert() { }
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) { }
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) { }

    // Business methods
    public static Voo__c criarVooRascunho(...) { }
}
```

#### Service Implementation Pattern

```apex
public class MissoesServiceImpl implements IMissoesService {

    public Map<Id, Missao__c> criarMissoes(
        fflib_ISObjectUnitOfWork uow,
        Map<Id, CalculoMissaoResult> mapVooCMR
    ) {
        // Business logic here
        Map<Id, Missao__c> mapVooMissao =
            Missoes.newInstance(new List<Missao__c>()).criarMissoes(mapVooCMR);

        // Register with UoW
        uow.registerNew(mapVooMissao.values());

        return mapVooMissao;
    }
}
```

### Testing Strategy

#### Test Data Factory
- **Primary**: `TestUtil2.cls` - Centralized test data creation
- **Pattern**: Builder pattern for complex test data

#### Test Coverage Requirements
- **Apex**: Minimum 75% (Salesforce requirement)
- **LWC**: Jest tests for all components
- **Integration**: Mock external callouts

#### Running Tests

```bash
# Apex Tests - All
sf apex run test --test-level RunLocalTests --result-format human

# Apex Tests - Specific class
sf apex run test --class-names MissoesServiceTest --result-format human

# LWC Tests - All
npm run test:unit

# LWC Tests - Watch mode
npm run test:unit:watch

# LWC Tests - Coverage
npm run test:unit:coverage

# LWC Tests - Specific component
sfdx-lwc-jest --testPathPattern=configurarVoo
```

### Code Quality

```bash
# Lint JavaScript
npm run lint

# Format code
npm run prettier

# Verify formatting
npm run prettier:verify
```

---

## 🚀 Deployment & Operations

### Environment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      PRODUCTION                             │
│                  (main branch)                              │
│              ↑                                              │
│              │ Validated Deploy                            │
│              │                                              │
├─────────────────────────────────────────────────────────────┤
│                         UAT                                 │
│                  (release/uat branch)                       │
│              ↑                                              │
│              │ Pull Request + Validation                   │
│              │                                              │
├─────────────────────────────────────────────────────────────┤
│                    DEV SANDBOX                              │
│                  (develop branch)                           │
│              ↑    [Shared by 4 developers]                 │
│              │ Pull Requests                               │
│              │                                              │
├─────────────────────────────────────────────────────────────┤
│         FEATURE BRANCHES & SCRATCH ORGS                     │
│     (feature/developer-name/description)                    │
└─────────────────────────────────────────────────────────────┘
```

### Git Workflow

**Branch Strategy**:
- `main` → Production (protected)
- `release/uat` → UAT Sandbox (protected)
- `develop` → Dev Sandbox (default, shared)
- `feature/*` → Personal scratch orgs or dev sandbox

**Important Rules**:
1. ⛔ **NEVER commit directly to `main`, `release/uat`, or `develop`**
2. ✅ Always create feature branches: `feature/developer-name/description`
3. ⚠️ Multiple developers share dev sandbox - **retrieve before deploying**
4. 🔍 Use scratch orgs for isolated feature development
5. 📝 Follow conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`

**Conventional Commit Examples**:
```
feat: Add shuttle seat availability caching
fix: Correct mission time calculation for multi-leg flights
refactor: Extract pricing logic to separate service
test: Add coverage for promo code validation
docs: Update README with integration patterns
```

### Deployment Commands

```bash
# Deploy to default org
sf project deploy start

# Deploy specific metadata
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls

# Deploy with tests (UAT/Production)
sf project deploy start --test-level RunLocalTests

# Validate without deploying (Production)
sf project deploy start --dry-run --test-level RunLocalTests

# Retrieve from org
sf project retrieve start --source-path force-app/main/default/classes/

# Retrieve specific metadata
sf project retrieve start --metadata ApexClass:MyClass
```

### Deployment Safety Checklist

**Before UAT Deployment**:
- [ ] All tests passing locally
- [ ] Code reviewed and approved
- [ ] Feature tested in dev sandbox
- [ ] Run validation with `--dry-run`
- [ ] Check deployment conflicts

**Before Production Deployment**:
- [ ] UAT testing complete and signed off
- [ ] All production deployment blockers resolved
- [ ] Backup plan documented
- [ ] **ALWAYS validate first** (never deploy directly)
- [ ] Run full test suite: `--test-level RunLocalTests`
- [ ] Schedule deployment during maintenance window
- [ ] Communication sent to stakeholders

### Multi-Developer Shared Sandbox Safety

**Problem**: 4 developers share the dev sandbox - risk of overwriting each other's work.

**Solution**: Always retrieve before deploy

```bash
# 1. Retrieve latest from org
sf project retrieve start --source-path force-app/main/default

# 2. Resolve any conflicts with your local changes

# 3. Deploy your changes
sf project deploy start --source-path force-app/main/default/classes/MyClass.cls

# 4. Commit to feature branch
git add .
git commit -m "feat: Add new feature"
git push origin feature/myname/new-feature
```

**See detailed workflows**:
- `WORKFLOW.md` - Complete promotion workflow (dev → uat → prod)
- `MULTI_DEV_WORKFLOW.md` - Multi-developer safety guide
- `SCRATCH_ORG_GUIDE.md` - Personal scratch org development

---

## 🔌 Integration Points

### External Systems

1. **Payment Gateways**
   - Multiple gateway support (configurable)
   - Stored in: `ConfiguracaoPagamento__c`
   - Transaction logs: `TransacaoGateway__c`

2. **Flight Management Systems**
   - Status: `StatusIntegraVoo` class
   - Logs: `LogIntegracao__c`

3. **Weather Services**
   - Weather data: `Meteograma__c`

4. **SkyTrac (Aircraft Tracking)**
   - Config: `ConfiguracoesIntegracaoSkyTrac__c`

5. **SAPIENS (Financial/Contract System)**
   - Config: `ConfiguracaoCodigoServicoSAPIENS__mdt`
   - Contract mapping: `TipoContratoSAPIENS__mdt`

### Platform Events

- `AtualizacaoDataVoo__e` - Flight date updates (event-driven)
- `HumorConta__e` - Account sentiment events

### Named Credentials
- Secure credential storage for external integrations
- Located: `force-app/main/default/namedCredentials/`

---

## 📚 Additional Documentation Files

- **CLAUDE.md** - AI assistant context and coding guidelines
- **WORKFLOW.md** - Complete environment promotion workflow
- **MULTI_DEV_WORKFLOW.md** - Multi-developer collaboration guide
- **SCRATCH_ORG_GUIDE.md** - Scratch org setup and usage

---

## 🛠️ MCP Integration

This project is configured with Salesforce MCP tools via `.mcp.json`:

**Available MCP Operations**:
- Org operations (create, delete, open, list)
- Metadata deploy/retrieve
- SOQL queries
- Scratch org creation/management
- Snapshot creation/restore
- Permission set assignment

**Org Aliases**: `dev`, `uat`, `prod`

---

## 📊 Project Metrics

- **Apex Classes**: 467
- **Apex Lines of Code**: ~150,000+ (estimated)
- **Custom Objects**: 64
- **Custom Metadata Types**: 32
- **Lightning Web Components**: 50
- **Aura Components**: 15
- **Flows**: 91
- **Triggers**: 8 (all delegated to domains)
- **Test Coverage**: Target 75%+

---

## 🌍 Localization

- **Primary Language**: Portuguese (Brazilian)
- **Market**: Brazil aviation sector
- **Labels**: Many labels and field names in Portuguese
- **Currency**: BRL (Brazilian Real) with multi-currency support via `TaxaMoeda__c`

---

## 📞 Support & Resources

### Salesforce Resources
- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

### Architecture Patterns
- [fflib-apex-common](https://github.com/apex-enterprise-patterns/fflib-apex-common)
- [Enterprise Patterns Overview](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl)

---

## 📝 Quick Reference

### Common Apex Patterns

```apex
// Service call pattern
IMissoesService service = (IMissoesService)
    Application.Service.newInstance(IMissoesService.class);

// Selector pattern
VoosSelector selector = (VoosSelector)
    Application.Selector.newInstance(Voo__c.SObjectType);

// Unit of Work pattern
fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
uow.registerNew(record);
uow.commitWork();

// Domain instantiation
Voos domain = Voos.newInstance(vooRecords);
```

### Key Status Values

**Voo__c (Flight) Status**:
- `Rascunho` - Draft
- `Pré-reservado` - Pre-reserved
- `Reservado` - Reserved
- `Confirmado` - Confirmed
- `Rota` - En Route
- `Executado` - Executed
- `Em Faturamento` - Invoicing
- `Faturado` - Invoiced
- `Cancelado` - Cancelled

**Pagamento__c (Payment) Status**:
- `Pendente` - Pending
- `Processando` - Processing
- `Aprovado` - Approved
- `Recusado` - Declined
- `Cancelado` - Cancelled
- `Estornado` - Refunded

---

**Version**: 1.0
**Last Updated**: 2025
**Salesforce API Version**: 64.0
**Project Name**: revo-dev
