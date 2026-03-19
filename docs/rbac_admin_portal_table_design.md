# RBAC Admin Portal table design (Oracle)

This design is derived from the portal screens in `rbac-admin-portal.html`:

- Module Management
- Pages / Sub-pages
- Actions & Privileges
- Role Management
- Geographic Scope (Country/Embassy)
- User Groups + Group Module Access
- User Master + User–Role Mapping

## Main tables

1. **Permission catalog**
   - `rbac_module`
   - `rbac_page`
   - `rbac_action`

2. **Role model**
   - `rbac_role`
   - `rbac_role_permission`
   - `rbac_role_country_scope`
   - `rbac_role_embassy_scope`

3. **User model**
   - `rbac_user_account`
   - `rbac_user_role`

4. **Group-based access**
   - `rbac_user_group`
   - `rbac_group_membership`
   - `rbac_group_role`
   - `rbac_group_permission`

5. **Reference/master**
   - `rbac_company`
   - `rbac_department`
   - `rbac_country`
   - `rbac_embassy`

6. **Audit**
   - `rbac_audit_log`

## Access models covered

- `USER_LINKED` (individual role assignment)
- `GEO_SCOPED` (role + country/embassy restriction)
- `GROUP_LINKED` (group-driven access by company/team)

## Notes for implementation

- `group_permission` is optional but useful when group access is configured directly in the Group Module Access screen (without creating many role variants).
- If your org chart is external, populate `rbac_group_membership` by sync job (e.g., LDAP/HRMS import).
- Effective permissions can be read from `v_rbac_effective_user_action`.
- Geo restrictions should be enforced in application query filters using:
  - `rbac_role_country_scope`
  - `rbac_role_embassy_scope`

## DDL script

Use:

`db/oracle/rbac_admin_portal_schema.sql`

Run with a privileged schema user (or adapt tablespace/storage clauses for your environment).
