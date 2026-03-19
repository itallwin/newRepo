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

## Bilingual support (English + Arabic)

- English text columns use suffix `En` (type: `VARCHAR2`)
- Arabic text columns use suffix `Ar` (type: `NVARCHAR2`)
- Implemented on all display/catalog fields, including:
  - Company / Department / Country / Embassy names
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

4. **Group-based access**
   - `TblMstRBACUserGroup`
   - `TblTrnRBACGroupMembership`
   - `TblTrnRBACGroupRole`
   - `TblTrnRBACPermission` (for `GranteeTypeCd='GROUP'`)

5. **Reference/master**
   - `TblMstRBACCompany`
   - `TblMstRBACDepartment`
   - `TblMstRBACCountry`
   - `TblMstRBACEmbassy`

6. **Audit**
   - `TblTrnRBACAuditLog`

## Access models covered

- `USER_LINKED` (individual role assignment)
- `GEO_SCOPED` (role + country/embassy restriction)
- `GROUP_LINKED` (group-driven access by company/team)

## Notes for implementation

- `TblTrnRBACPermission` handles both role and group permissions:
  - `GranteeTypeCd='ROLE'` + `RoleUno`
  - `GranteeTypeCd='GROUP'` + `UserGroupUno`
- `StatusCd` has been replaced with `IsActive` across the schema.
- Roles are soft-delete friendly:
  - active uniqueness is enforced with function-based unique indexes on `RoleCode` and `RoleNameEn` only when `DeletedOn IS NULL`
  - this allows deleting a role and re-creating the same role code/name later
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
