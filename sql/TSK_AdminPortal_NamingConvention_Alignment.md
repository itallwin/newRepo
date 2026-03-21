# TSK Schema Naming Convention Alignment (Admin Portal Style)

This task module follows the same naming convention pattern used in the Admin portal table design style.

## 1) Table naming
- Master tables: `TblMstTSK...`
- Transaction tables: `TblTrnTSK...`

Examples:
- Master: `TblMstTSKUser`, `TblMstTSKProject`, `TblMstTSKPriority`
- Transaction: `TblTrnTSKTask`, `TblTrnTSKTaskComment`, `TblTrnTSKTaskAttachment`

## 2) ID naming and type
- Key column naming: `<Entity>NameId` (e.g., `TaskUno`, `UserUo`, `ProjectId`)
- ID data type: `dbo.Uno` (alias of `UNIQUEIDENTIFIER`)
- Primary IDs default: `NEWSEQUENTIALID()` for better clustered-index insert behavior

## 3) Constraint naming
- Default constraints: `DF_<TableName>_<ColumnName>`
- Check constraints: `CK_<TableName>_<RuleName>`
- Foreign keys: `FK_<TableName>_<ReferencedEntity>`

## 4) Index naming
- Unique indexes: `UX_<TableName>_<BusinessKeyOrPurpose>`
- Non-unique indexes: `IX_<TableName>_<FilterOrAccessPath>`

## 5) Bilingual column naming (English/Arabic)
- Text columns use `...En` and `...Ar` suffixes where required:
  - `TaskTitleEn`, `TaskTitleAr`
  - `CommentEn`, `CommentAr`
  - `DescriptionEn`, `DescriptionAr`

## 6) Audit and lifecycle columns
- Standard columns are kept consistent across tables:
  - `IsActive`, `IsDeleted`
  - `EnteredOn`, `EnteredBy`
  - `ModifiedOn`, `ModifiedBy`
  - `RowVer` (rowversion)

## 7) Status check
- Current schema `sql/TSK_SQLServer_Schema.sql` is aligned to this convention for all `TblMstTSK...` and `TblTrnTSK...` objects.
