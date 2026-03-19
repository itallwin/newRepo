# Service Desk table design (Oracle)

This schema follows the same convention used in your Admin Portal design:

- Master tables: `TblMstSD...`
- Transaction tables: `TblTrnSD...`
- Primary keys: `...Uno` identity columns
- Common lifecycle/audit columns: `IsActive`, `EnteredOn/By`, `ModifiedOn/By`, `DeletedOn/By`

DDL file:

- `db/oracle/service_desk_schema.sql`
- single-schema deployment wrapper: `db/oracle/deploy_service_desk_single_schema.sql`

## Single schema consolidation

All tables are designed to be created in one schema owner (single Oracle schema).

Use:

- `db/oracle/deploy_service_desk_single_schema.sql`

This wrapper script:

1. Creates one schema owner (configurable; default `SDOPS`)
2. Grants required object privileges
3. Sets current schema to that owner
4. Executes `service_desk_schema.sql` so all `TblMstSD...` and `TblTrnSD...` objects are consolidated in that same schema

## Core coverage (menus + operations)

### L1 / L2 / L3 / manager queues

- `TblMstSDSupportLevel`
- `TblMstSDTeam`
- `TblMstSDUser`
- Queue state in `TblTrnSDTicket`:
  - `CurrentSupportLevelUno`
  - `CurrentTeamUno`
  - `AssignedToUserUno`
- Assignment history:
  - `TblTrnSDTicketAssignment`

### Escalation and auto-escalation

- Manual/actual escalations:
  - `TblTrnSDEscalation`
- Auto-escalation configuration:
  - `TblMstSDAutoEscalationRule`
- Auto-escalation execution audit:
  - `TblTrnSDAutoEscalationAudit`
- Auto escalation candidates view:
  - `VRptSDAutoEscalationDue`

### Incident / SR / Problem / Change

- Type master:
  - `TblMstSDTicketType`
- Common ticket entity:
  - `TblTrnSDTicket`
- Type extensions:
  - `TblTrnSDServiceRequest`
  - `TblTrnSDProblem`
  - `TblTrnSDChangeRequest`

### Problem suggestion from repeated patterns

- Pattern cluster store:
  - `TblTrnSDPatternCluster`
  - `TblTrnSDPatternTicket`
- Suggested problems:
  - `TblTrnSDProblemSuggestion`
- Live candidate view (from repeated Incident/SR patterns):
  - `VRptSDProblemSuggestionCandidate`

### Problem management + KEDB

- Problem details:
  - `TblTrnSDProblem` (`RootCauseText`, `WorkaroundText`, `IsKnownError`)
- Linking incidents/problems:
  - `TblTrnSDTicketLink`
- Knowledge/KEDB:
  - `TblTrnSDKBArticle`
  - `TblTrnSDKBArticleTicket`
  - `TblTrnSDKBArticleTag`

### Change + CAB

- Change details:
  - `TblTrnSDChangeRequest`
- CAB decision audit:
  - `TblTrnSDCABDecision`
- CAB group master:
  - `TblMstSDCABGroup`

### Customer follow-up + status tracking

- Follow-up entries on a ticket:
  - `TblTrnSDTicketFollowUp`
- Timeline and notes:
  - `TblTrnSDTicketWorkflow`
  - `TblTrnSDTicketComment`
- Ticket SLA due fields in ticket:
  - `ResponseSlaDueOn`
  - `ResolutionSlaDueOn`
  - `FirstBreachedOn`

### Feedback and improvement suggestions

- Categorization master:
  - `TblMstSDFeedbackCategory`
- Feedback/suggestion transaction:
  - `TblTrnSDFeedback`
- Supports:
  - type = feedback/suggestion
  - category, impact area, acceptance, action status

### Quality control (audit team review)

- Review checklist master:
  - `TblMstSDQualityParameter`
- Ticket review header:
  - `TblTrnSDTicketQualityReview`
- Parameter-level scoring:
  - `TblTrnSDTicketQualityReviewItem`

### Manager / change manager / problem manager oversight

- Periodic case review header:
  - `TblTrnSDManagerCaseReview`
- Reviewed ticket links:
  - `TblTrnSDManagerCaseReviewTicket`
- Corrective action tracker:
  - `TblTrnSDCorrectiveAction`

## Multi-source intake (CRM, call center, support center, apps, GRC)

- Source system master:
  - `TblMstSDSourceSystem`
- Inbound source transaction:
  - `TblTrnSDSourceTransaction`
- One SR to one source transaction:
  - `TblTrnSDServiceRequest.SourceTxnUno` (unique)

Uniqueness controls:

- `TblTrnSDSourceTransaction`: `(SourceSystemUno, SourceTxnRefNo)` unique
- `TblTrnSDServiceRequest`: `(SourceTxnUno)` unique

## SLA and KPI reporting

### Org hierarchy for SLA slices

- `TblMstSDDepartment`
- `TblMstSDSection`
- user/team references include department + section
- ticket stores requester department/section snapshot columns

### Automatic KPI views (live)

- Agent dashboard KPI + delays:
  - `VRptSDAgentKPILive`
- Overall KPI:
  - `VRptSDOverallKPILive`
- Department SLA:
  - `VRptSDDepartmentSLALive`
- Section SLA:
  - `VRptSDSectionSLALive`
- Weekly/Monthly/Quarterly SR impact summary:
  - `VRptSDServiceRequestSummaryPeriod`

### KPI persistence (period snapshots)

- `TblTrnSDKPISnapshot`
  - Period type: weekly/monthly/quarterly
  - Scope: overall/department/section/agent
  - Metric code + value

## Recommended application/service validations

1. Ensure `TblTrnSDServiceRequest.TicketUno` is only for `TicketType='SERVICE_REQUEST'`.
2. Derive priority from `TblMstSDPriorityMatrix` (impact x urgency).
3. Write all transitions to `TblTrnSDTicketWorkflow`.
4. On escalation, log:
   - `TblTrnSDEscalation`
   - `TblTrnSDTicketAssignment` (if owner changes)
5. For CAB decisions:
   - insert `TblTrnSDCABDecision`
   - update `TblTrnSDChangeRequest.CABStatusCode`
6. For quality review closure:
   - compute/store `OverallScorePercent`
   - create `TblTrnSDCorrectiveAction` when threshold is not met
7. For monthly/weekly/quarterly reporting:
   - schedule snapshot job to load `TblTrnSDKPISnapshot` from live views.

