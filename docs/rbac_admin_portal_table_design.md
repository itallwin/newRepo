# RBAC Admin Portal table design (Oracle)

This design is derived from the portal screens in `rbac-admin-portal.html`:

- Module Management
- Pages / Sub-pages
- Actions & Privileges
- Role Management
- Geographic Scope (Country/Embassy)
- User Groups + Group Module Access
- User Master + User–Role Mapping

## Naming convention applied

- Master tables: `TblMstRBAC...`
- Transaction tables: `TblTrnRBAC...`
- Primary keys: `...Uno` (example: `UserUno`, `RoleUno`, `PermissionUno`)
- Every table has an identity primary key.
- All tables include `IsActive NUMBER(1)` (1 = active, 0 = inactive).
- Standard audit fields are:
  - `EnteredOn`, `EnteredBy`
  - `ModifiedOn`, `ModifiedBy`
  - `DeletedOn`, `DeletedBy`
- Inactivation/activation lifecycle fields use `...On` naming:
  - `InactiveOn`, `InactivatedOn`, `InactivatedBy`
  - `ActivatedOn`, `ActivatedBy`

## Bilingual support (English + Arabic)

- English text columns use suffix `En` (type: `VARCHAR2`)
- Arabic text columns use suffix `Ar` (type: `NVARCHAR2`)
- Implemented on all display/catalog fields, including:
  - Company / Department / Division / Section / Country / Embassy names
  - Module / Page / Action / Role names and descriptions
  - User Group names and descriptions
  - User first/last name and designation

## Main tables

1. **Permission catalog**
   - `TblMstRBACModule`
   - `TblMstRBACPage`
   - `TblMstRBACAction`

2. **Role model**
   - `TblMstRBACRole`
   - `TblTrnRBACPermission`
   - `TblTrnRBACRoleCountryScope`
   - `TblTrnRBACRoleEmbassyScope`

3. **User model**
   - `TblMstRBACUser`
   - `TblTrnRBACUserRole`
   - `TblMstRBACAllowedEmailDomain` (email whitelist)
   - `TblTrnRBACUserReactRequest` (reactivation request)
   - `TblTrnRBACUserReactApproval` (reactivation approval steps)
   - User org links: `CompanyUno`, `DepartmentUno`, `DivisionUno`, `SectionUno`
   - Compliance:
     - Department + Division mandatory, Section optional
     - Account lock after 3 failed password attempts
     - Password history retained in `TblTrnRBACUserPasswordHistory` (keep latest 5 by policy/job)
     - First/Last login fields on user profile

4. **Group-based access**
   - `TblMstRBACUserGroup`
   - `TblTrnRBACGroupMembership`
   - `TblTrnRBACGroupRole`
   - `TblTrnRBACPermission` (for `GranteeTypeCode='GROUP'`)

5. **Reference/master**
   - `TblMstRBACCompany`
   - `TblMstRBACDepartment`
   - `TblMstRBACDivision`
   - `TblMstRBACSection`
   - `TblMstRBACCountry`
   - `TblMstRBACEmbassy`

6. **Audit**
   - `TblTrnRBACAuditLog`
   - `TblTrnRBACUserLoginAudit` (login attempts)
   - `TblTrnRBACUserSecurityAudit` (security events)
   - `TblTrnRBACPermissionAudit` (all permission inserts/updates/deletes)
   - `TblTrnRBACUserReviewAudit` (review campaign audit trail)

7. **Compliance review**
   - `TblTrnRBACUserReviewCampaign`
   - `TblTrnRBACUserReviewItem`

## Access models covered

- `USER_LINKED` (individual role assignment)
- `GEO_SCOPED` (role + country/embassy restriction)
- `GROUP_LINKED` (group-driven access by company/team)

## Notes for implementation

- `TblTrnRBACPermission` handles both role and group permissions:
  - `GranteeTypeCode='ROLE'` + `RoleUno`
  - `GranteeTypeCode='GROUP'` + `UserGroupUno`
- `StatusCode` has been replaced with `IsActive` across the schema.
- Roles are soft-delete friendly:
  - active uniqueness is enforced with function-based unique indexes on `RoleCode` and `RoleNameEn` only when `DeletedOn IS NULL`
  - this allows deleting a role and re-creating the same role code/name later
- Users are linked to full organization hierarchy:
  - Department (`DepartmentUno`)
  - Division (`DivisionUno`)
  - Section (`SectionUno`)
- Password/compliance controls:
  - `TblMstRBACUser` has failed-attempt lock controls (`FailedPasswordAttemptCount`, `IsAccountLocked`, `AccountLockedOn`)
  - `CK_MstUser_LockRule` enforces lock when failed attempts are 3 or more
  - Password history is recorded in `TblTrnRBACUserPasswordHistory`; enforce "last 5" at app/service layer or with scheduled purge job
- Reactivation workflow:
  - Requests are raised in `TblTrnRBACUserReactRequest`
  - Approval decisions are captured in `TblTrnRBACUserReactApproval`
  - Final reactivation actor/time is stored with `ReactivatedByUserUno`, `ReactivatedOn`
- Email domain controls:
  - User create/update is validated against `TblMstRBACAllowedEmailDomain`
  - Trigger `TRG_MstUser_ValEmailDomain` blocks non-whitelisted domains
- Permission change auditing:
  - `TRG_TrnRBACPermAudit` writes every permission `INSERT/UPDATE/DELETE` to `TblTrnRBACPermissionAudit`
  - captures old/new values, action type, changed timestamp and actor text (`ChangedBy`)
- For UI language selection:
  - Show `*Ar` values when language = Arabic
  - Fallback to `*En` when Arabic value is null
- If your org chart is external, populate `TblTrnRBACGroupMembership` by sync job (e.g., LDAP/HRMS import).
- Effective permissions can be read from `VRBACEffectiveUserAction`.
- Geo restrictions should be enforced in application query filters using:
  - `TblTrnRBACRoleCountryScope`
  - `TblTrnRBACRoleEmbassyScope`

## DDL script

Use:

`db/oracle/rbac_admin_portal_schema.sql`

Run with a privileged schema user (or adapt tablespace/storage clauses for your environment).
