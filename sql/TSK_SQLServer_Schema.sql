/*
  Task Management v2 - SQL Server schema
  Naming standard:
    - Master tables:      TblMstTSK...
    - Transaction tables: TblTrnTSK...
  Notes:
    - NVARCHAR is used for bilingual English/Arabic support.
    - Includes tenant-ready design, audit columns, soft-delete flags, and rowversion.
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   MASTER SCREENS
   ========================================================= */

CREATE TABLE dbo.TblMstTSKTenant (
    TenantId            BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantCode          VARCHAR(30) NOT NULL,
    TenantNameEn        NVARCHAR(200) NOT NULL,
    TenantNameAr        NVARCHAR(200) NOT NULL,
    DefaultCultureCode  VARCHAR(10) NOT NULL CONSTRAINT DF_TblMstTSKTenant_DefaultCultureCode DEFAULT ('en'),
    TimeZoneId          NVARCHAR(100) NOT NULL CONSTRAINT DF_TblMstTSKTenant_TimeZoneId DEFAULT (N'UTC'),
    IsActive            BIT NOT NULL CONSTRAINT DF_TblMstTSKTenant_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKTenant_IsDeleted DEFAULT (0),
    CreatedOnUtc        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTenant_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId     BIGINT NULL,
    ModifiedOnUtc       DATETIME2(3) NULL,
    ModifiedByUserId    BIGINT NULL,
    RowVer              ROWVERSION NOT NULL
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTenant_TenantCode_Active
ON dbo.TblMstTSKTenant (TenantCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKCompany (
    CompanyId           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId            BIGINT NOT NULL,
    CompanyCode         VARCHAR(30) NOT NULL,
    CompanyNameEn       NVARCHAR(200) NOT NULL,
    CompanyNameAr       NVARCHAR(200) NOT NULL,
    DescriptionEn       NVARCHAR(500) NULL,
    DescriptionAr       NVARCHAR(500) NULL,
    IsActive            BIT NOT NULL CONSTRAINT DF_TblMstTSKCompany_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKCompany_IsDeleted DEFAULT (0),
    CreatedOnUtc        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKCompany_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId     BIGINT NULL,
    ModifiedOnUtc       DATETIME2(3) NULL,
    ModifiedByUserId    BIGINT NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKCompany_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKCompany_Tenant_CompanyCode_Active
ON dbo.TblMstTSKCompany (TenantId, CompanyCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKBranch (
    BranchId            BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId            BIGINT NOT NULL,
    CompanyId           BIGINT NOT NULL,
    BranchCode          VARCHAR(30) NOT NULL,
    BranchNameEn        NVARCHAR(200) NOT NULL,
    BranchNameAr        NVARCHAR(200) NOT NULL,
    AddressEn           NVARCHAR(500) NULL,
    AddressAr           NVARCHAR(500) NULL,
    CityEn              NVARCHAR(100) NULL,
    CityAr              NVARCHAR(100) NULL,
    CountryCode         CHAR(2) NULL,
    IsActive            BIT NOT NULL CONSTRAINT DF_TblMstTSKBranch_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKBranch_IsDeleted DEFAULT (0),
    CreatedOnUtc        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKBranch_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId     BIGINT NULL,
    ModifiedOnUtc       DATETIME2(3) NULL,
    ModifiedByUserId    BIGINT NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKBranch_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblMstTSKBranch_Company FOREIGN KEY (CompanyId) REFERENCES dbo.TblMstTSKCompany (CompanyId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKBranch_Tenant_BranchCode_Active
ON dbo.TblMstTSKBranch (TenantId, BranchCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKDepartment (
    DepartmentId        BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId            BIGINT NOT NULL,
    CompanyId           BIGINT NOT NULL,
    BranchId            BIGINT NULL,
    DepartmentCode      VARCHAR(30) NOT NULL,
    DepartmentNameEn    NVARCHAR(200) NOT NULL,
    DepartmentNameAr    NVARCHAR(200) NOT NULL,
    DescriptionEn       NVARCHAR(500) NULL,
    DescriptionAr       NVARCHAR(500) NULL,
    IsActive            BIT NOT NULL CONSTRAINT DF_TblMstTSKDepartment_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKDepartment_IsDeleted DEFAULT (0),
    CreatedOnUtc        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKDepartment_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId     BIGINT NULL,
    ModifiedOnUtc       DATETIME2(3) NULL,
    ModifiedByUserId    BIGINT NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKDepartment_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblMstTSKDepartment_Company FOREIGN KEY (CompanyId) REFERENCES dbo.TblMstTSKCompany (CompanyId),
    CONSTRAINT FK_TblMstTSKDepartment_Branch FOREIGN KEY (BranchId) REFERENCES dbo.TblMstTSKBranch (BranchId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKDepartment_Tenant_DepartmentCode_Active
ON dbo.TblMstTSKDepartment (TenantId, DepartmentCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKRole (
    RoleId              BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId            BIGINT NOT NULL,
    RoleCode            VARCHAR(30) NOT NULL,
    RoleNameEn          NVARCHAR(150) NOT NULL,
    RoleNameAr          NVARCHAR(150) NOT NULL,
    DescriptionEn       NVARCHAR(500) NULL,
    DescriptionAr       NVARCHAR(500) NULL,
    IsSystemRole        BIT NOT NULL CONSTRAINT DF_TblMstTSKRole_IsSystemRole DEFAULT (0),
    IsActive            BIT NOT NULL CONSTRAINT DF_TblMstTSKRole_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKRole_IsDeleted DEFAULT (0),
    CreatedOnUtc        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKRole_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId     BIGINT NULL,
    ModifiedOnUtc       DATETIME2(3) NULL,
    ModifiedByUserId    BIGINT NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKRole_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKRole_Tenant_RoleCode_Active
ON dbo.TblMstTSKRole (TenantId, RoleCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKUser (
    UserId                  BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId                BIGINT NOT NULL,
    EmployeeNo              VARCHAR(30) NULL,
    LoginName               VARCHAR(120) NOT NULL,
    FullNameEn              NVARCHAR(200) NOT NULL,
    FullNameAr              NVARCHAR(200) NULL,
    Email                   VARCHAR(254) NOT NULL,
    MobileNo                VARCHAR(30) NULL,
    DepartmentId            BIGINT NULL,
    DefaultRoleId           BIGINT NULL,
    PreferredLanguageCode   VARCHAR(10) NOT NULL CONSTRAINT DF_TblMstTSKUser_PreferredLanguageCode DEFAULT ('en'),
    PasswordHash            VARBINARY(8000) NULL,
    LastLoginUtc            DATETIME2(3) NULL,
    IsLocked                BIT NOT NULL CONSTRAINT DF_TblMstTSKUser_IsLocked DEFAULT (0),
    IsActive                BIT NOT NULL CONSTRAINT DF_TblMstTSKUser_IsActive DEFAULT (1),
    IsDeleted               BIT NOT NULL CONSTRAINT DF_TblMstTSKUser_IsDeleted DEFAULT (0),
    CreatedOnUtc            DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKUser_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId         BIGINT NULL,
    ModifiedOnUtc           DATETIME2(3) NULL,
    ModifiedByUserId        BIGINT NULL,
    RowVer                  ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKUser_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblMstTSKUser_Department FOREIGN KEY (DepartmentId) REFERENCES dbo.TblMstTSKDepartment (DepartmentId),
    CONSTRAINT FK_TblMstTSKUser_DefaultRole FOREIGN KEY (DefaultRoleId) REFERENCES dbo.TblMstTSKRole (RoleId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKUser_Tenant_LoginName_Active
ON dbo.TblMstTSKUser (TenantId, LoginName)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKUser_Tenant_Email_Active
ON dbo.TblMstTSKUser (TenantId, Email)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKProject (
    ProjectId            BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId             BIGINT NOT NULL,
    ProjectCode          VARCHAR(30) NOT NULL,
    ProjectNameEn        NVARCHAR(250) NOT NULL,
    ProjectNameAr        NVARCHAR(250) NOT NULL,
    DescriptionEn        NVARCHAR(MAX) NULL,
    DescriptionAr        NVARCHAR(MAX) NULL,
    CompanyId            BIGINT NULL,
    DepartmentId         BIGINT NULL,
    ProjectManagerUserId BIGINT NULL,
    PlannedStartUtc      DATETIME2(3) NULL,
    PlannedEndUtc        DATETIME2(3) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_TblMstTSKProject_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKProject_IsDeleted DEFAULT (0),
    CreatedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKProject_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId      BIGINT NULL,
    ModifiedOnUtc        DATETIME2(3) NULL,
    ModifiedByUserId     BIGINT NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKProject_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblMstTSKProject_Company FOREIGN KEY (CompanyId) REFERENCES dbo.TblMstTSKCompany (CompanyId),
    CONSTRAINT FK_TblMstTSKProject_Department FOREIGN KEY (DepartmentId) REFERENCES dbo.TblMstTSKDepartment (DepartmentId),
    CONSTRAINT FK_TblMstTSKProject_Manager FOREIGN KEY (ProjectManagerUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKProject_Tenant_ProjectCode_Active
ON dbo.TblMstTSKProject (TenantId, ProjectCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKTaskType (
    TaskTypeId           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId             BIGINT NOT NULL,
    TaskTypeCode         VARCHAR(30) NOT NULL,
    TaskTypeNameEn       NVARCHAR(150) NOT NULL,
    TaskTypeNameAr       NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    DisplayOrder         INT NOT NULL CONSTRAINT DF_TblMstTSKTaskType_DisplayOrder DEFAULT (0),
    IsActive             BIT NOT NULL CONSTRAINT DF_TblMstTSKTaskType_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKTaskType_IsDeleted DEFAULT (0),
    CreatedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTaskType_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId      BIGINT NULL,
    ModifiedOnUtc        DATETIME2(3) NULL,
    ModifiedByUserId     BIGINT NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKTaskType_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTaskType_Tenant_TaskTypeCode_Active
ON dbo.TblMstTSKTaskType (TenantId, TaskTypeCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKPriority (
    PriorityId           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId             BIGINT NOT NULL,
    PriorityCode         VARCHAR(30) NOT NULL,
    PriorityNameEn       NVARCHAR(150) NOT NULL,
    PriorityNameAr       NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    SeverityRank         TINYINT NOT NULL,
    ColorHex             CHAR(7) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_TblMstTSKPriority_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKPriority_IsDeleted DEFAULT (0),
    CreatedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKPriority_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId      BIGINT NULL,
    ModifiedOnUtc        DATETIME2(3) NULL,
    ModifiedByUserId     BIGINT NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKPriority_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKPriority_Tenant_PriorityCode_Active
ON dbo.TblMstTSKPriority (TenantId, PriorityCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKStatus (
    StatusId             BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId             BIGINT NOT NULL,
    StatusCode           VARCHAR(30) NOT NULL,
    StatusNameEn         NVARCHAR(150) NOT NULL,
    StatusNameAr         NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    IsClosedStatus       BIT NOT NULL CONSTRAINT DF_TblMstTSKStatus_IsClosedStatus DEFAULT (0),
    DisplayOrder         INT NOT NULL CONSTRAINT DF_TblMstTSKStatus_DisplayOrder DEFAULT (0),
    IsActive             BIT NOT NULL CONSTRAINT DF_TblMstTSKStatus_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKStatus_IsDeleted DEFAULT (0),
    CreatedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKStatus_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId      BIGINT NULL,
    ModifiedOnUtc        DATETIME2(3) NULL,
    ModifiedByUserId     BIGINT NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKStatus_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKStatus_Tenant_StatusCode_Active
ON dbo.TblMstTSKStatus (TenantId, StatusCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKCategory (
    CategoryId           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId             BIGINT NOT NULL,
    CategoryCode         VARCHAR(30) NOT NULL,
    CategoryNameEn       NVARCHAR(150) NOT NULL,
    CategoryNameAr       NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    ParentCategoryId     BIGINT NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_TblMstTSKCategory_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKCategory_IsDeleted DEFAULT (0),
    CreatedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKCategory_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId      BIGINT NULL,
    ModifiedOnUtc        DATETIME2(3) NULL,
    ModifiedByUserId     BIGINT NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKCategory_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblMstTSKCategory_ParentCategory FOREIGN KEY (ParentCategoryId) REFERENCES dbo.TblMstTSKCategory (CategoryId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKCategory_Tenant_CategoryCode_Active
ON dbo.TblMstTSKCategory (TenantId, CategoryCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKTag (
    TagId                BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId             BIGINT NOT NULL,
    TagCode              VARCHAR(40) NOT NULL,
    TagNameEn            NVARCHAR(100) NOT NULL,
    TagNameAr            NVARCHAR(100) NULL,
    ColorHex             CHAR(7) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_TblMstTSKTag_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKTag_IsDeleted DEFAULT (0),
    CreatedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTag_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId      BIGINT NULL,
    ModifiedOnUtc        DATETIME2(3) NULL,
    ModifiedByUserId     BIGINT NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKTag_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTag_Tenant_TagCode_Active
ON dbo.TblMstTSKTag (TenantId, TagCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKScreen (
    ScreenId             BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId             BIGINT NOT NULL,
    ScreenCode           VARCHAR(40) NOT NULL,
    ScreenNameEn         NVARCHAR(150) NOT NULL,
    ScreenNameAr         NVARCHAR(150) NOT NULL,
    RoutePath            NVARCHAR(300) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_TblMstTSKScreen_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKScreen_IsDeleted DEFAULT (0),
    CreatedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKScreen_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId      BIGINT NULL,
    ModifiedOnUtc        DATETIME2(3) NULL,
    ModifiedByUserId     BIGINT NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKScreen_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKScreen_Tenant_ScreenCode_Active
ON dbo.TblMstTSKScreen (TenantId, ScreenCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKRolePermission (
    RolePermissionId      BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    RoleId                BIGINT NOT NULL,
    ScreenId              BIGINT NOT NULL,
    CanView               BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanView DEFAULT (0),
    CanAdd                BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanAdd DEFAULT (0),
    CanEdit               BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanEdit DEFAULT (0),
    CanDelete             BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanDelete DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKRolePermission_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblMstTSKRolePermission_Role FOREIGN KEY (RoleId) REFERENCES dbo.TblMstTSKRole (RoleId),
    CONSTRAINT FK_TblMstTSKRolePermission_Screen FOREIGN KEY (ScreenId) REFERENCES dbo.TblMstTSKScreen (ScreenId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKRolePermission_UQ
ON dbo.TblMstTSKRolePermission (TenantId, RoleId, ScreenId)
WHERE IsDeleted = 0;
GO

/* =========================================================
   TRANSACTION SCREENS
   ========================================================= */

CREATE TABLE dbo.TblTrnTSKTask (
    TaskId                BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskNo                VARCHAR(40) NOT NULL,
    ProjectId             BIGINT NOT NULL,
    CategoryId            BIGINT NULL,
    TaskTypeId            BIGINT NOT NULL,
    PriorityId            BIGINT NOT NULL,
    StatusId              BIGINT NOT NULL,
    ParentTaskId          BIGINT NULL,
    RequestedByUserId     BIGINT NULL,
    OwnerUserId           BIGINT NULL,
    TaskTitleEn           NVARCHAR(300) NOT NULL,
    TaskTitleAr           NVARCHAR(300) NULL,
    TaskDescriptionEn     NVARCHAR(MAX) NULL,
    TaskDescriptionAr     NVARCHAR(MAX) NULL,
    PlannedStartUtc       DATETIME2(3) NULL,
    DueUtc                DATETIME2(3) NULL,
    ActualStartUtc        DATETIME2(3) NULL,
    ActualEndUtc          DATETIME2(3) NULL,
    EstimatedHours        DECIMAL(10,2) NULL,
    ActualHours           DECIMAL(10,2) NULL,
    CompletedPercent      DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblTrnTSKTask_CompletedPercent DEFAULT (0),
    IsMilestone           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTask_IsMilestone DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTask_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTask_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTask_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKTask_CompletedPercent CHECK (CompletedPercent >= 0 AND CompletedPercent <= 100),
    CONSTRAINT FK_TblTrnTSKTask_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTask_Project FOREIGN KEY (ProjectId) REFERENCES dbo.TblMstTSKProject (ProjectId),
    CONSTRAINT FK_TblTrnTSKTask_Category FOREIGN KEY (CategoryId) REFERENCES dbo.TblMstTSKCategory (CategoryId),
    CONSTRAINT FK_TblTrnTSKTask_TaskType FOREIGN KEY (TaskTypeId) REFERENCES dbo.TblMstTSKTaskType (TaskTypeId),
    CONSTRAINT FK_TblTrnTSKTask_Priority FOREIGN KEY (PriorityId) REFERENCES dbo.TblMstTSKPriority (PriorityId),
    CONSTRAINT FK_TblTrnTSKTask_Status FOREIGN KEY (StatusId) REFERENCES dbo.TblMstTSKStatus (StatusId),
    CONSTRAINT FK_TblTrnTSKTask_ParentTask FOREIGN KEY (ParentTaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTask_RequestedBy FOREIGN KEY (RequestedByUserId) REFERENCES dbo.TblMstTSKUser (UserId),
    CONSTRAINT FK_TblTrnTSKTask_Owner FOREIGN KEY (OwnerUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTask_Tenant_TaskNo_Active
ON dbo.TblTrnTSKTask (TenantId, TaskNo)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTask_Tenant_Status_Due
ON dbo.TblTrnTSKTask (TenantId, StatusId, DueUtc)
INCLUDE (PriorityId, OwnerUserId, ProjectId, CompletedPercent)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTask_Tenant_Project
ON dbo.TblTrnTSKTask (TenantId, ProjectId, CreatedOnUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskAssignment (
    TaskAssignmentId      BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    AssigneeUserId        BIGINT NOT NULL,
    AssignedByUserId      BIGINT NULL,
    AssignedOnUtc         DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_AssignedOnUtc DEFAULT (SYSUTCDATETIME()),
    IsPrimaryAssignee     BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_IsPrimaryAssignee DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskAssignment_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskAssignment_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskAssignment_Assignee FOREIGN KEY (AssigneeUserId) REFERENCES dbo.TblMstTSKUser (UserId),
    CONSTRAINT FK_TblTrnTSKTaskAssignment_AssignedBy FOREIGN KEY (AssignedByUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskAssignment_UQ
ON dbo.TblTrnTSKTaskAssignment (TenantId, TaskId, AssigneeUserId)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTaskAssignment_Assignee
ON dbo.TblTrnTSKTaskAssignment (TenantId, AssigneeUserId, IsPrimaryAssignee)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskChecklist (
    ChecklistId           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    ChecklistTitleEn      NVARCHAR(250) NOT NULL,
    ChecklistTitleAr      NVARCHAR(250) NULL,
    DisplayOrder          INT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_DisplayOrder DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskChecklist_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskChecklist_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId)
);
GO

CREATE TABLE dbo.TblTrnTSKTaskChecklistItem (
    ChecklistItemId       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    ChecklistId           BIGINT NOT NULL,
    ItemTextEn            NVARCHAR(300) NOT NULL,
    ItemTextAr            NVARCHAR(300) NULL,
    IsMandatory           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsMandatory DEFAULT (0),
    IsCompleted           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsCompleted DEFAULT (0),
    CompletedByUserId     BIGINT NULL,
    CompletedOnUtc        DATETIME2(3) NULL,
    DisplayOrder          INT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_DisplayOrder DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskChecklistItem_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskChecklistItem_Checklist FOREIGN KEY (ChecklistId) REFERENCES dbo.TblTrnTSKTaskChecklist (ChecklistId),
    CONSTRAINT FK_TblTrnTSKTaskChecklistItem_CompletedBy FOREIGN KEY (CompletedByUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO

CREATE TABLE dbo.TblTrnTSKTaskComment (
    TaskCommentId         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    CommentEn             NVARCHAR(MAX) NULL,
    CommentAr             NVARCHAR(MAX) NULL,
    IsInternal            BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_IsInternal DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskComment_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskComment_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskComment_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE INDEX IX_TblTrnTSKTaskComment_Task_CreatedOn
ON dbo.TblTrnTSKTaskComment (TenantId, TaskId, CreatedOnUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskAttachment (
    TaskAttachmentId      BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    FileNameOriginal      NVARCHAR(255) NOT NULL,
    FileExtension         VARCHAR(20) NULL,
    MimeType              VARCHAR(120) NULL,
    FileSizeBytes         BIGINT NULL,
    StorageProvider       VARCHAR(50) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_StorageProvider DEFAULT ('DB'),
    StoragePath           NVARCHAR(500) NULL,
    FileHashSha256        CHAR(64) NULL,
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskAttachment_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskAttachment_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskAttachment_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE INDEX IX_TblTrnTSKTaskAttachment_Task
ON dbo.TblTrnTSKTaskAttachment (TenantId, TaskId, CreatedOnUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskTimeLog (
    TaskTimeLogId         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    UserId                BIGINT NOT NULL,
    WorkDate              DATE NOT NULL,
    StartUtc              DATETIME2(3) NULL,
    EndUtc                DATETIME2(3) NULL,
    DurationMinutes       INT NOT NULL,
    NotesEn               NVARCHAR(1000) NULL,
    NotesAr               NVARCHAR(1000) NULL,
    IsBillable            BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_IsBillable DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKTaskTimeLog_DurationMinutes CHECK (DurationMinutes > 0),
    CONSTRAINT FK_TblTrnTSKTaskTimeLog_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskTimeLog_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskTimeLog_User FOREIGN KEY (UserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE INDEX IX_TblTrnTSKTaskTimeLog_User_WorkDate
ON dbo.TblTrnTSKTaskTimeLog (TenantId, UserId, WorkDate)
INCLUDE (TaskId, DurationMinutes)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskStatusHistory (
    TaskStatusHistoryId   BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    FromStatusId          BIGINT NULL,
    ToStatusId            BIGINT NOT NULL,
    ChangeReasonEn        NVARCHAR(1000) NULL,
    ChangeReasonAr        NVARCHAR(1000) NULL,
    ChangedByUserId       BIGINT NULL,
    ChangedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_ChangedOnUtc DEFAULT (SYSUTCDATETIME()),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_FromStatus FOREIGN KEY (FromStatusId) REFERENCES dbo.TblMstTSKStatus (StatusId),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_ToStatus FOREIGN KEY (ToStatusId) REFERENCES dbo.TblMstTSKStatus (StatusId),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_ChangedBy FOREIGN KEY (ChangedByUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE INDEX IX_TblTrnTSKTaskStatusHistory_Task_ChangedOn
ON dbo.TblTrnTSKTaskStatusHistory (TenantId, TaskId, ChangedOnUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskDependency (
    TaskDependencyId      BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    DependsOnTaskId       BIGINT NOT NULL,
    DependencyTypeCode    VARCHAR(20) NOT NULL, -- FS, SS, FF, SF
    LagMinutes            INT NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_LagMinutes DEFAULT (0),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskDependency_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskDependency_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskDependency_DependsOn FOREIGN KEY (DependsOnTaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT CK_TblTrnTSKTaskDependency_NoSelf CHECK (TaskId <> DependsOnTaskId)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskDependency_UQ
ON dbo.TblTrnTSKTaskDependency (TenantId, TaskId, DependsOnTaskId)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskTagMap (
    TaskTagMapId          BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    TagId                 BIGINT NOT NULL,
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTagMap_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTagMap_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskTagMap_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskTagMap_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskTagMap_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskTagMap_Tag FOREIGN KEY (TagId) REFERENCES dbo.TblMstTSKTag (TagId)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskTagMap_UQ
ON dbo.TblTrnTSKTaskTagMap (TenantId, TaskId, TagId)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskWatcher (
    TaskWatcherId         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    UserId                BIGINT NOT NULL,
    NotifyByEmail         BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_NotifyByEmail DEFAULT (1),
    NotifyInApp           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_NotifyInApp DEFAULT (1),
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskWatcher_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskWatcher_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskWatcher_User FOREIGN KEY (UserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskWatcher_UQ
ON dbo.TblTrnTSKTaskWatcher (TenantId, TaskId, UserId)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskApproval (
    TaskApprovalId        BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    TaskId                BIGINT NOT NULL,
    ApproverUserId        BIGINT NOT NULL,
    ApprovalStatusCode    VARCHAR(20) NOT NULL, -- Pending/Approved/Rejected
    ApprovalRemarksEn     NVARCHAR(1000) NULL,
    ApprovalRemarksAr     NVARCHAR(1000) NULL,
    DecisionOnUtc         DATETIME2(3) NULL,
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskApproval_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskApproval_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskApproval_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskApproval_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKTaskApproval_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId),
    CONSTRAINT FK_TblTrnTSKTaskApproval_Approver FOREIGN KEY (ApproverUserId) REFERENCES dbo.TblMstTSKUser (UserId)
);
GO
CREATE INDEX IX_TblTrnTSKTaskApproval_Approver_Status
ON dbo.TblTrnTSKTaskApproval (TenantId, ApproverUserId, ApprovalStatusCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKNotification (
    NotificationId        BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId              BIGINT NOT NULL,
    UserId                BIGINT NOT NULL,
    TaskId                BIGINT NULL,
    NotificationTypeCode  VARCHAR(30) NOT NULL,
    TitleEn               NVARCHAR(250) NOT NULL,
    TitleAr               NVARCHAR(250) NULL,
    MessageEn             NVARCHAR(1000) NULL,
    MessageAr             NVARCHAR(1000) NULL,
    IsRead                BIT NOT NULL CONSTRAINT DF_TblTrnTSKNotification_IsRead DEFAULT (0),
    ReadOnUtc             DATETIME2(3) NULL,
    IsActive              BIT NOT NULL CONSTRAINT DF_TblTrnTSKNotification_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKNotification_IsDeleted DEFAULT (0),
    CreatedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKNotification_CreatedOnUtc DEFAULT (SYSUTCDATETIME()),
    CreatedByUserId       BIGINT NULL,
    ModifiedOnUtc         DATETIME2(3) NULL,
    ModifiedByUserId      BIGINT NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKNotification_Tenant FOREIGN KEY (TenantId) REFERENCES dbo.TblMstTSKTenant (TenantId),
    CONSTRAINT FK_TblTrnTSKNotification_User FOREIGN KEY (UserId) REFERENCES dbo.TblMstTSKUser (UserId),
    CONSTRAINT FK_TblTrnTSKNotification_Task FOREIGN KEY (TaskId) REFERENCES dbo.TblTrnTSKTask (TaskId)
);
GO
CREATE INDEX IX_TblTrnTSKNotification_User_IsRead_CreatedOn
ON dbo.TblTrnTSKNotification (TenantId, UserId, IsRead, CreatedOnUtc)
WHERE IsDeleted = 0;
GO

/* =========================================================
   END OF SCHEMA
   ========================================================= */
