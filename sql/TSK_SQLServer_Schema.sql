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

IF TYPE_ID(N'dbo.Uno') IS NULL
    EXEC('CREATE TYPE dbo.Uno FROM UNIQUEIDENTIFIER NULL;');
GO

/* =========================================================
   MASTER SCREENS
   ========================================================= */

CREATE TABLE dbo.TblMstTSKTenant (
    TenantUno            dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKTenant_TenantUno DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantCode          VARCHAR(30) NOT NULL,
    TenantNameEn        NVARCHAR(200) NOT NULL,
    TenantNameAr        NVARCHAR(200) NOT NULL,
    DefaultCultureCode  VARCHAR(10) NOT NULL CONSTRAINT DF_TblMstTSKTenant_DefaultCultureCode DEFAULT ('en'),
    TimeZoneId          NVARCHAR(100) NOT NULL CONSTRAINT DF_TblMstTSKTenant_TimeZoneId DEFAULT (N'UTC'),
    IsActive            TINYINT NOT NULL CONSTRAINT DF_TblMstTSKTenant_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKTenant_IsDeleted DEFAULT (0),
    EnteredOn        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTenant_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy     dbo.Uno NULL,
    ModifiedOn       DATETIME2(3) NULL,
    ModifiedBy    dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer              ROWVERSION NOT NULL
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTenant_TenantCode_Active
ON dbo.TblMstTSKTenant (TenantCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKCompany (
    CompanyId           dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKCompany_CompanyId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno            dbo.Uno NOT NULL,
    CompanyCode         VARCHAR(30) NOT NULL,
    CompanyNameEn       NVARCHAR(200) NOT NULL,
    CompanyNameAr       NVARCHAR(200) NOT NULL,
    DescriptionEn       NVARCHAR(500) NULL,
    DescriptionAr       NVARCHAR(500) NULL,
    IsActive            TINYINT NOT NULL CONSTRAINT DF_TblMstTSKCompany_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKCompany_IsDeleted DEFAULT (0),
    EnteredOn        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKCompany_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy     dbo.Uno NULL,
    ModifiedOn       DATETIME2(3) NULL,
    ModifiedBy    dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKCompany_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKCompany_Tenant_CompanyCode_Active
ON dbo.TblMstTSKCompany (TenantUno, CompanyCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKBranch (
    BranchId            dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKBranch_BranchId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno            dbo.Uno NOT NULL,
    CompanyId           dbo.Uno NOT NULL,
    BranchCode          VARCHAR(30) NOT NULL,
    BranchNameEn        NVARCHAR(200) NOT NULL,
    BranchNameAr        NVARCHAR(200) NOT NULL,
    AddressEn           NVARCHAR(500) NULL,
    AddressAr           NVARCHAR(500) NULL,
    CityEn              NVARCHAR(100) NULL,
    CityAr              NVARCHAR(100) NULL,
    CountryCode         CHAR(2) NULL,
    IsActive            TINYINT NOT NULL CONSTRAINT DF_TblMstTSKBranch_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKBranch_IsDeleted DEFAULT (0),
    EnteredOn        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKBranch_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy     dbo.Uno NULL,
    ModifiedOn       DATETIME2(3) NULL,
    ModifiedBy    dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKBranch_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblMstTSKBranch_Company FOREIGN KEY (CompanyId) REFERENCES dbo.TblMstTSKCompany (CompanyId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKBranch_Tenant_BranchCode_Active
ON dbo.TblMstTSKBranch (TenantUno, BranchCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKDepartment (
    DepartmentId        dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKDepartment_DepartmentId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno            dbo.Uno NOT NULL,
    CompanyId           dbo.Uno NOT NULL,
    BranchId            dbo.Uno NULL,
    DepartmentCode      VARCHAR(30) NOT NULL,
    DepartmentNameEn    NVARCHAR(200) NOT NULL,
    DepartmentNameAr    NVARCHAR(200) NOT NULL,
    DescriptionEn       NVARCHAR(500) NULL,
    DescriptionAr       NVARCHAR(500) NULL,
    IsActive            TINYINT NOT NULL CONSTRAINT DF_TblMstTSKDepartment_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKDepartment_IsDeleted DEFAULT (0),
    EnteredOn        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKDepartment_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy     dbo.Uno NULL,
    ModifiedOn       DATETIME2(3) NULL,
    ModifiedBy    dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKDepartment_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblMstTSKDepartment_Company FOREIGN KEY (CompanyId) REFERENCES dbo.TblMstTSKCompany (CompanyId),
    CONSTRAINT FK_TblMstTSKDepartment_Branch FOREIGN KEY (BranchId) REFERENCES dbo.TblMstTSKBranch (BranchId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKDepartment_Tenant_DepartmentCode_Active
ON dbo.TblMstTSKDepartment (TenantUno, DepartmentCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKRole (
    RoleId              dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKRole_RoleId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno            dbo.Uno NOT NULL,
    RoleCode            VARCHAR(30) NOT NULL,
    RoleNameEn          NVARCHAR(150) NOT NULL,
    RoleNameAr          NVARCHAR(150) NOT NULL,
    DescriptionEn       NVARCHAR(500) NULL,
    DescriptionAr       NVARCHAR(500) NULL,
    IsSystemRole        BIT NOT NULL CONSTRAINT DF_TblMstTSKRole_IsSystemRole DEFAULT (0),
    IsActive            TINYINT NOT NULL CONSTRAINT DF_TblMstTSKRole_IsActive DEFAULT (1),
    IsDeleted           BIT NOT NULL CONSTRAINT DF_TblMstTSKRole_IsDeleted DEFAULT (0),
    EnteredOn        DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKRole_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy     dbo.Uno NULL,
    ModifiedOn       DATETIME2(3) NULL,
    ModifiedBy    dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer              ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKRole_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKRole_Tenant_RoleCode_Active
ON dbo.TblMstTSKRole (TenantUno, RoleCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKUser (
    UserUo                  dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKUser_UserUo DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno                dbo.Uno NOT NULL,
    EmployeeNo              VARCHAR(30) NULL,
    LoginName               VARCHAR(120) NOT NULL,
    FullNameEn              NVARCHAR(200) NOT NULL,
    FullNameAr              NVARCHAR(200) NULL,
    JobTitleEn              NVARCHAR(120) NULL,
    JobTitleAr              NVARCHAR(120) NULL,
    Email                   VARCHAR(254) NOT NULL,
    MobileNo                VARCHAR(30) NULL,
    CurrentPresenceStatusCode VARCHAR(15) NOT NULL CONSTRAINT DF_TblMstTSKUser_CurrentPresenceStatusCode DEFAULT ('Offline'),
    CapacityHoursPerWeek    DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblMstTSKUser_CapacityHoursPerWeek DEFAULT (40),
    DepartmentId            dbo.Uno NULL,
    DefaultRoleId           dbo.Uno NULL,
    PreferredLanguageCode   VARCHAR(10) NOT NULL CONSTRAINT DF_TblMstTSKUser_PreferredLanguageCode DEFAULT ('en'),
    PasswordHash            VARBINARY(8000) NULL,
    LastLoginUtc            DATETIME2(3) NULL,
    IsLocked                BIT NOT NULL CONSTRAINT DF_TblMstTSKUser_IsLocked DEFAULT (0),
    IsActive                TINYINT NOT NULL CONSTRAINT DF_TblMstTSKUser_IsActive DEFAULT (1),
    IsDeleted               BIT NOT NULL CONSTRAINT DF_TblMstTSKUser_IsDeleted DEFAULT (0),
    EnteredOn            DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKUser_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy         dbo.Uno NULL,
    ModifiedOn           DATETIME2(3) NULL,
    ModifiedBy        dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                  ROWVERSION NOT NULL,
    CONSTRAINT CK_TblMstTSKUser_CapacityHoursPerWeek CHECK (CapacityHoursPerWeek > 0 AND CapacityHoursPerWeek <= 168),
    CONSTRAINT FK_TblMstTSKUser_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblMstTSKUser_Department FOREIGN KEY (DepartmentId) REFERENCES dbo.TblMstTSKDepartment (DepartmentId),
    CONSTRAINT FK_TblMstTSKUser_DefaultRole FOREIGN KEY (DefaultRoleId) REFERENCES dbo.TblMstTSKRole (RoleId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKUser_Tenant_LoginName_Active
ON dbo.TblMstTSKUser (TenantUno, LoginName)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKUser_Tenant_Email_Active
ON dbo.TblMstTSKUser (TenantUno, Email)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKTeam (
    TeamId                dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKTeam_TeamId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TeamCode              VARCHAR(30) NOT NULL,
    TeamNameEn            NVARCHAR(150) NOT NULL,
    TeamNameAr            NVARCHAR(150) NULL,
    DescriptionEn         NVARCHAR(500) NULL,
    DescriptionAr         NVARCHAR(500) NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblMstTSKTeam_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblMstTSKTeam_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTeam_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKTeam_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTeam_Tenant_TeamCode_Active
ON dbo.TblMstTSKTeam (TenantUno, TeamCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKTeamMember (
    TeamMemberId          dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKTeamMember_TeamMemberId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TeamId                dbo.Uno NOT NULL,
    UserUo                dbo.Uno NOT NULL,
    MemberRoleCode        VARCHAR(30) NULL, -- Lead/Member/Observer
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblMstTSKTeamMember_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblMstTSKTeamMember_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTeamMember_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKTeamMember_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblMstTSKTeamMember_Team FOREIGN KEY (TeamId) REFERENCES dbo.TblMstTSKTeam (TeamId),
    CONSTRAINT FK_TblMstTSKTeamMember_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTeamMember_UQ
ON dbo.TblMstTSKTeamMember (TenantUno, TeamId, UserUo)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblMstTSKTeamMember_Team
ON dbo.TblMstTSKTeamMember (TenantUno, TeamId, UserUo)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKProject (
    ProjectId            dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKProject_ProjectId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno             dbo.Uno NOT NULL,
    ProjectCode          VARCHAR(30) NOT NULL,
    ProjectNameEn        NVARCHAR(250) NOT NULL,
    ProjectNameAr        NVARCHAR(250) NOT NULL,
    DescriptionEn        NVARCHAR(MAX) NULL,
    DescriptionAr        NVARCHAR(MAX) NULL,
    CompanyId            dbo.Uno NULL,
    DepartmentId         dbo.Uno NULL,
    ProjectManagerUserUo dbo.Uno NULL,
    PortfolioStatusCode  VARCHAR(20) NOT NULL CONSTRAINT DF_TblMstTSKProject_PortfolioStatusCode DEFAULT ('OnTrack'),
    ProgressPercent      DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblMstTSKProject_ProgressPercent DEFAULT (0),
    RiskNoteEn           NVARCHAR(1000) NULL,
    RiskNoteAr           NVARCHAR(1000) NULL,
    HealthReviewedOnUtc  DATETIME2(3) NULL,
    PlannedStartUtc      DATETIME2(3) NULL,
    PlannedEndUtc        DATETIME2(3) NULL,
    IsActive             TINYINT NOT NULL CONSTRAINT DF_TblMstTSKProject_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKProject_IsDeleted DEFAULT (0),
    EnteredOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKProject_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy      dbo.Uno NULL,
    ModifiedOn        DATETIME2(3) NULL,
    ModifiedBy     dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT CK_TblMstTSKProject_ProgressPercent CHECK (ProgressPercent >= 0 AND ProgressPercent <= 100),
    CONSTRAINT FK_TblMstTSKProject_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblMstTSKProject_Company FOREIGN KEY (CompanyId) REFERENCES dbo.TblMstTSKCompany (CompanyId),
    CONSTRAINT FK_TblMstTSKProject_Department FOREIGN KEY (DepartmentId) REFERENCES dbo.TblMstTSKDepartment (DepartmentId),
    CONSTRAINT FK_TblMstTSKProject_Manager FOREIGN KEY (ProjectManagerUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKProject_Tenant_ProjectCode_Active
ON dbo.TblMstTSKProject (TenantUno, ProjectCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKTaskType (
    TaskTypeId           dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKTaskType_TaskTypeId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno             dbo.Uno NOT NULL,
    TaskTypeCode         VARCHAR(30) NOT NULL,
    TaskTypeNameEn       NVARCHAR(150) NOT NULL,
    TaskTypeNameAr       NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    DisplayOrder         INT NOT NULL CONSTRAINT DF_TblMstTSKTaskType_DisplayOrder DEFAULT (0),
    IsActive             TINYINT NOT NULL CONSTRAINT DF_TblMstTSKTaskType_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKTaskType_IsDeleted DEFAULT (0),
    EnteredOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTaskType_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy      dbo.Uno NULL,
    ModifiedOn        DATETIME2(3) NULL,
    ModifiedBy     dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKTaskType_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTaskType_Tenant_TaskTypeCode_Active
ON dbo.TblMstTSKTaskType (TenantUno, TaskTypeCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKPriority (
    PriorityId           dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKPriority_PriorityId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno             dbo.Uno NOT NULL,
    PriorityCode         VARCHAR(30) NOT NULL,
    PriorityNameEn       NVARCHAR(150) NOT NULL,
    PriorityNameAr       NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    SeverityRank         TINYINT NOT NULL,
    ColorHex             CHAR(7) NULL,
    IsActive             TINYINT NOT NULL CONSTRAINT DF_TblMstTSKPriority_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKPriority_IsDeleted DEFAULT (0),
    EnteredOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKPriority_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy      dbo.Uno NULL,
    ModifiedOn        DATETIME2(3) NULL,
    ModifiedBy     dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKPriority_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKPriority_Tenant_PriorityCode_Active
ON dbo.TblMstTSKPriority (TenantUno, PriorityCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKStatus (
    StatusId             dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKStatus_StatusId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno             dbo.Uno NOT NULL,
    StatusCode           VARCHAR(30) NOT NULL,
    StatusNameEn         NVARCHAR(150) NOT NULL,
    StatusNameAr         NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    IsClosedStatus       BIT NOT NULL CONSTRAINT DF_TblMstTSKStatus_IsClosedStatus DEFAULT (0),
    DisplayOrder         INT NOT NULL CONSTRAINT DF_TblMstTSKStatus_DisplayOrder DEFAULT (0),
    IsActive             TINYINT NOT NULL CONSTRAINT DF_TblMstTSKStatus_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKStatus_IsDeleted DEFAULT (0),
    EnteredOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKStatus_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy      dbo.Uno NULL,
    ModifiedOn        DATETIME2(3) NULL,
    ModifiedBy     dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKStatus_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKStatus_Tenant_StatusCode_Active
ON dbo.TblMstTSKStatus (TenantUno, StatusCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKCategory (
    CategoryId           dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKCategory_CategoryId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno             dbo.Uno NOT NULL,
    CategoryCode         VARCHAR(30) NOT NULL,
    CategoryNameEn       NVARCHAR(150) NOT NULL,
    CategoryNameAr       NVARCHAR(150) NOT NULL,
    DescriptionEn        NVARCHAR(500) NULL,
    DescriptionAr        NVARCHAR(500) NULL,
    ParentCategoryId     dbo.Uno NULL,
    IsActive             TINYINT NOT NULL CONSTRAINT DF_TblMstTSKCategory_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKCategory_IsDeleted DEFAULT (0),
    EnteredOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKCategory_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy      dbo.Uno NULL,
    ModifiedOn        DATETIME2(3) NULL,
    ModifiedBy     dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKCategory_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblMstTSKCategory_ParentCategory FOREIGN KEY (ParentCategoryId) REFERENCES dbo.TblMstTSKCategory (CategoryId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKCategory_Tenant_CategoryCode_Active
ON dbo.TblMstTSKCategory (TenantUno, CategoryCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKTag (
    TagId                dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKTag_TagId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno             dbo.Uno NOT NULL,
    TagCode              VARCHAR(40) NOT NULL,
    TagNameEn            NVARCHAR(100) NOT NULL,
    TagNameAr            NVARCHAR(100) NULL,
    ColorHex             CHAR(7) NULL,
    IsActive             TINYINT NOT NULL CONSTRAINT DF_TblMstTSKTag_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKTag_IsDeleted DEFAULT (0),
    EnteredOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKTag_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy      dbo.Uno NULL,
    ModifiedOn        DATETIME2(3) NULL,
    ModifiedBy     dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKTag_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKTag_Tenant_TagCode_Active
ON dbo.TblMstTSKTag (TenantUno, TagCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKScreen (
    ScreenId             dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKScreen_ScreenId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno             dbo.Uno NOT NULL,
    ScreenCode           VARCHAR(40) NOT NULL,
    ScreenNameEn         NVARCHAR(150) NOT NULL,
    ScreenNameAr         NVARCHAR(150) NOT NULL,
    RoutePath            NVARCHAR(300) NULL,
    IsActive             TINYINT NOT NULL CONSTRAINT DF_TblMstTSKScreen_IsActive DEFAULT (1),
    IsDeleted            BIT NOT NULL CONSTRAINT DF_TblMstTSKScreen_IsDeleted DEFAULT (0),
    EnteredOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKScreen_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy      dbo.Uno NULL,
    ModifiedOn        DATETIME2(3) NULL,
    ModifiedBy     dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer               ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKScreen_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKScreen_Tenant_ScreenCode_Active
ON dbo.TblMstTSKScreen (TenantUno, ScreenCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblMstTSKRolePermission (
    RolePermissionId      dbo.Uno  NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_RolePermissionId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    RoleId                dbo.Uno NOT NULL,
    ScreenId              dbo.Uno NOT NULL,
    CanView               BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanView DEFAULT (0),
    CanAdd                BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanAdd DEFAULT (0),
    CanEdit               BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanEdit DEFAULT (0),
    CanDelete             BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_CanDelete DEFAULT (0),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblMstTSKRolePermission_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblMstTSKRolePermission_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblMstTSKRolePermission_Role FOREIGN KEY (RoleId) REFERENCES dbo.TblMstTSKRole (RoleId),
    CONSTRAINT FK_TblMstTSKRolePermission_Screen FOREIGN KEY (ScreenId) REFERENCES dbo.TblMstTSKScreen (ScreenId)
);
GO
CREATE UNIQUE INDEX UX_TblMstTSKRolePermission_UQ
ON dbo.TblMstTSKRolePermission (TenantUno, RoleId, ScreenId)
WHERE IsDeleted = 0;
GO

/* Additional uniqueness for duplicate prevention (soft-delete aware) */
CREATE UNIQUE INDEX UX_TblMstTSKTenant_TenantNameEn_Active
ON dbo.TblMstTSKTenant (TenantNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKTenant_TenantNameAr_Active
ON dbo.TblMstTSKTenant (TenantNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKCompany_Tenant_CompanyNameEn_Active
ON dbo.TblMstTSKCompany (TenantUno, CompanyNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKCompany_Tenant_CompanyNameAr_Active
ON dbo.TblMstTSKCompany (TenantUno, CompanyNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKBranch_Tenant_Company_BranchNameEn_Active
ON dbo.TblMstTSKBranch (TenantUno, CompanyId, BranchNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKBranch_Tenant_Company_BranchNameAr_Active
ON dbo.TblMstTSKBranch (TenantUno, CompanyId, BranchNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKDepartment_Tenant_Company_DepartmentNameEn_Active
ON dbo.TblMstTSKDepartment (TenantUno, CompanyId, DepartmentNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKDepartment_Tenant_Company_DepartmentNameAr_Active
ON dbo.TblMstTSKDepartment (TenantUno, CompanyId, DepartmentNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKRole_Tenant_RoleNameEn_Active
ON dbo.TblMstTSKRole (TenantUno, RoleNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKRole_Tenant_RoleNameAr_Active
ON dbo.TblMstTSKRole (TenantUno, RoleNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKUser_Tenant_EmployeeNo_Active
ON dbo.TblMstTSKUser (TenantUno, EmployeeNo)
WHERE IsDeleted = 0 AND EmployeeNo IS NOT NULL;
GO
CREATE UNIQUE INDEX UX_TblMstTSKUser_Tenant_MobileNo_Active
ON dbo.TblMstTSKUser (TenantUno, MobileNo)
WHERE IsDeleted = 0 AND MobileNo IS NOT NULL;
GO

CREATE UNIQUE INDEX UX_TblMstTSKTeam_Tenant_TeamNameEn_Active
ON dbo.TblMstTSKTeam (TenantUno, TeamNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKTeam_Tenant_TeamNameAr_Active
ON dbo.TblMstTSKTeam (TenantUno, TeamNameAr)
WHERE IsDeleted = 0 AND TeamNameAr IS NOT NULL;
GO

CREATE UNIQUE INDEX UX_TblMstTSKProject_Tenant_ProjectNameEn_Active
ON dbo.TblMstTSKProject (TenantUno, ProjectNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKProject_Tenant_ProjectNameAr_Active
ON dbo.TblMstTSKProject (TenantUno, ProjectNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKTaskType_Tenant_TaskTypeNameEn_Active
ON dbo.TblMstTSKTaskType (TenantUno, TaskTypeNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKTaskType_Tenant_TaskTypeNameAr_Active
ON dbo.TblMstTSKTaskType (TenantUno, TaskTypeNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKPriority_Tenant_PriorityNameEn_Active
ON dbo.TblMstTSKPriority (TenantUno, PriorityNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKPriority_Tenant_PriorityNameAr_Active
ON dbo.TblMstTSKPriority (TenantUno, PriorityNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKStatus_Tenant_StatusNameEn_Active
ON dbo.TblMstTSKStatus (TenantUno, StatusNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKStatus_Tenant_StatusNameAr_Active
ON dbo.TblMstTSKStatus (TenantUno, StatusNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKCategory_Tenant_Parent_CategoryNameEn_Active
ON dbo.TblMstTSKCategory (TenantUno, ParentCategoryId, CategoryNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKCategory_Tenant_Parent_CategoryNameAr_Active
ON dbo.TblMstTSKCategory (TenantUno, ParentCategoryId, CategoryNameAr)
WHERE IsDeleted = 0;
GO

CREATE UNIQUE INDEX UX_TblMstTSKTag_Tenant_TagNameEn_Active
ON dbo.TblMstTSKTag (TenantUno, TagNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKTag_Tenant_TagNameAr_Active
ON dbo.TblMstTSKTag (TenantUno, TagNameAr)
WHERE IsDeleted = 0 AND TagNameAr IS NOT NULL;
GO

CREATE UNIQUE INDEX UX_TblMstTSKScreen_Tenant_ScreenNameEn_Active
ON dbo.TblMstTSKScreen (TenantUno, ScreenNameEn)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKScreen_Tenant_ScreenNameAr_Active
ON dbo.TblMstTSKScreen (TenantUno, ScreenNameAr)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblMstTSKScreen_Tenant_RoutePath_Active
ON dbo.TblMstTSKScreen (TenantUno, RoutePath)
WHERE IsDeleted = 0 AND RoutePath IS NOT NULL;
GO

/* =========================================================
   TRANSACTION SCREENS
   ========================================================= */

CREATE TABLE dbo.TblTrnTSKTask (
    TaskUno                dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTask_TaskUno DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskNo                VARCHAR(40) NOT NULL,
    ProjectId             dbo.Uno NOT NULL,
    TeamId                dbo.Uno NULL,
    CategoryId            dbo.Uno NULL,
    TaskTypeId            dbo.Uno NOT NULL,
    PriorityId            dbo.Uno NOT NULL,
    StatusId              dbo.Uno NOT NULL,
    ParentTaskUno          dbo.Uno NULL,
    RequestedByUserUo     dbo.Uno NULL,
    OwnerUserUo           dbo.Uno NULL,
    TaskTitleEn           NVARCHAR(300) NOT NULL,
    TaskTitleAr           NVARCHAR(300) NULL,
    TaskDescriptionEn     NVARCHAR(MAX) NULL,
    TaskDescriptionAr     NVARCHAR(MAX) NULL,
    TaskGroupEn           NVARCHAR(150) NULL,
    TaskGroupAr           NVARCHAR(150) NULL,
    PlannedStartUtc       DATETIME2(3) NULL,
    DueUtc                DATETIME2(3) NOT NULL,
    ActualStartUtc        DATETIME2(3) NULL,
    ActualEndUtc          DATETIME2(3) NULL,
    CompletedOnUtc        DATETIME2(3) NULL,
    EstimatedHours        DECIMAL(10,2) NULL,
    ActualHours           DECIMAL(10,2) NULL,
    CompletedPercent      DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblTrnTSKTask_CompletedPercent DEFAULT (0),
    IsMilestone           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTask_IsMilestone DEFAULT (0),
    IsArchived            BIT NOT NULL CONSTRAINT DF_TblTrnTSKTask_IsArchived DEFAULT (0),
    ArchivedOnUtc         DATETIME2(3) NULL,
    ArchivedByUserUo      dbo.Uno NULL,
    ArchiveReasonEn       NVARCHAR(1000) NULL,
    ArchiveReasonAr       NVARCHAR(1000) NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTask_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTask_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTask_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKTask_CompletedPercent CHECK (CompletedPercent >= 0 AND CompletedPercent <= 100),
    CONSTRAINT FK_TblTrnTSKTask_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTask_Project FOREIGN KEY (ProjectId) REFERENCES dbo.TblMstTSKProject (ProjectId),
    CONSTRAINT FK_TblTrnTSKTask_Team FOREIGN KEY (TeamId) REFERENCES dbo.TblMstTSKTeam (TeamId),
    CONSTRAINT FK_TblTrnTSKTask_Category FOREIGN KEY (CategoryId) REFERENCES dbo.TblMstTSKCategory (CategoryId),
    CONSTRAINT FK_TblTrnTSKTask_TaskType FOREIGN KEY (TaskTypeId) REFERENCES dbo.TblMstTSKTaskType (TaskTypeId),
    CONSTRAINT FK_TblTrnTSKTask_Priority FOREIGN KEY (PriorityId) REFERENCES dbo.TblMstTSKPriority (PriorityId),
    CONSTRAINT FK_TblTrnTSKTask_Status FOREIGN KEY (StatusId) REFERENCES dbo.TblMstTSKStatus (StatusId),
    CONSTRAINT FK_TblTrnTSKTask_ParentTask FOREIGN KEY (ParentTaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTask_RequestedBy FOREIGN KEY (RequestedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKTask_Owner FOREIGN KEY (OwnerUserUo) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKTask_ArchivedBy FOREIGN KEY (ArchivedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTask_Tenant_TaskNo_Active
ON dbo.TblTrnTSKTask (TenantUno, TaskNo)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTask_Tenant_Status_Due
ON dbo.TblTrnTSKTask (TenantUno, StatusId, DueUtc)
INCLUDE (PriorityId, OwnerUserUo, ProjectId, CompletedPercent)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTask_BoardLane
ON dbo.TblTrnTSKTask (TenantUno, StatusId, DueUtc, PriorityId)
INCLUDE (ProjectId, OwnerUserUo, TaskTitleEn, CompletedPercent)
WHERE IsDeleted = 0 AND IsArchived = 0;
GO
CREATE INDEX IX_TblTrnTSKTask_Tenant_Project
ON dbo.TblTrnTSKTask (TenantUno, ProjectId, EnteredOn)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTask_Team_Due
ON dbo.TblTrnTSKTask (TenantUno, TeamId, DueUtc)
INCLUDE (StatusId, PriorityId, OwnerUserUo, TaskTitleEn)
WHERE IsDeleted = 0 AND IsArchived = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskAssignment (
    TaskAssignmentId      dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_TaskAssignmentId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    AssigneeUserUo        dbo.Uno NOT NULL,
    AssignedBy      dbo.Uno NULL,
    AssignedOn         DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_AssignedOn DEFAULT (SYSUTCDATETIME()),
    IsPrimaryAssignee     BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_IsPrimaryAssignee DEFAULT (0),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAssignment_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskAssignment_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskAssignment_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskAssignment_Assignee FOREIGN KEY (AssigneeUserUo) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKTaskAssignment_AssignedBy FOREIGN KEY (AssignedBy) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskAssignment_UQ
ON dbo.TblTrnTSKTaskAssignment (TenantUno, TaskUno, AssigneeUserUo)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskAssignment_Primary
ON dbo.TblTrnTSKTaskAssignment (TenantUno, TaskUno)
WHERE IsDeleted = 0 AND IsPrimaryAssignee = 1;
GO
CREATE INDEX IX_TblTrnTSKTaskAssignment_Assignee
ON dbo.TblTrnTSKTaskAssignment (TenantUno, AssigneeUserUo, IsPrimaryAssignee)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskSubtask (
    TaskSubtaskId          dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskSubtask_TaskSubtaskId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    TaskUno                 dbo.Uno NOT NULL,
    SubtaskTitleEn         NVARCHAR(300) NOT NULL,
    SubtaskTitleAr         NVARCHAR(300) NULL,
    DisplayOrder           INT NOT NULL CONSTRAINT DF_TblTrnTSKTaskSubtask_DisplayOrder DEFAULT (0),
    IsCompleted            BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskSubtask_IsCompleted DEFAULT (0),
    CompletedByUserUo      dbo.Uno NULL,
    CompletedOnUtc         DATETIME2(3) NULL,
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskSubtask_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskSubtask_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskSubtask_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskSubtask_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskSubtask_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskSubtask_CompletedBy FOREIGN KEY (CompletedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskSubtask_Task
ON dbo.TblTrnTSKTaskSubtask (TenantUno, TaskUno, DisplayOrder)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskChecklist (
    ChecklistId           dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_ChecklistId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    ChecklistTitleEn      NVARCHAR(250) NOT NULL,
    ChecklistTitleAr      NVARCHAR(250) NULL,
    DisplayOrder          INT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_DisplayOrder DEFAULT (0),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklist_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskChecklist_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskChecklist_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno)
);
GO

CREATE TABLE dbo.TblTrnTSKTaskChecklistItem (
    ChecklistItemId       dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_ChecklistItemId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    ChecklistId           dbo.Uno NOT NULL,
    ItemTextEn            NVARCHAR(300) NOT NULL,
    ItemTextAr            NVARCHAR(300) NULL,
    IsMandatory           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsMandatory DEFAULT (0),
    IsCompleted           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsCompleted DEFAULT (0),
    CompletedByUserUo     dbo.Uno NULL,
    CompletedOnUtc        DATETIME2(3) NULL,
    DisplayOrder          INT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_DisplayOrder DEFAULT (0),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskChecklistItem_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskChecklistItem_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskChecklistItem_Checklist FOREIGN KEY (ChecklistId) REFERENCES dbo.TblTrnTSKTaskChecklist (ChecklistId),
    CONSTRAINT FK_TblTrnTSKTaskChecklistItem_CompletedBy FOREIGN KEY (CompletedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO

CREATE TABLE dbo.TblTrnTSKTaskComment (
    TaskCommentId         dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_TaskCommentId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    ParentTaskCommentId   dbo.Uno NULL,
    CommentEn             NVARCHAR(MAX) NULL,
    CommentAr             NVARCHAR(MAX) NULL,
    ClientMessageRef      VARCHAR(80) NULL,
    IsInternal            BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_IsInternal DEFAULT (0),
    IsEdited              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_IsEdited DEFAULT (0),
    EditedOnUtc           DATETIME2(3) NULL,
    EditedByUserUo        dbo.Uno NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskComment_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKTaskComment_TextRequired CHECK (
        LEN(LTRIM(RTRIM(ISNULL(CommentEn, N'')))) > 0
        OR LEN(LTRIM(RTRIM(ISNULL(CommentAr, N'')))) > 0
    ),
    CONSTRAINT FK_TblTrnTSKTaskComment_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskComment_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskComment_Parent FOREIGN KEY (ParentTaskCommentId) REFERENCES dbo.TblTrnTSKTaskComment (TaskCommentId),
    CONSTRAINT FK_TblTrnTSKTaskComment_CreatedBy FOREIGN KEY (EnteredBy) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKTaskComment_EditedBy FOREIGN KEY (EditedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskComment_Task_CreatedOn
ON dbo.TblTrnTSKTaskComment (TenantUno, TaskUno, EnteredOn DESC)
INCLUDE (EnteredBy, IsEdited, EditedOnUtc)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTaskComment_Parent_CreatedOn
ON dbo.TblTrnTSKTaskComment (TenantUno, ParentTaskCommentId, EnteredOn DESC)
WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskComment_ClientMessageRef
ON dbo.TblTrnTSKTaskComment (TenantUno, TaskUno, ClientMessageRef)
WHERE IsDeleted = 0 AND ClientMessageRef IS NOT NULL;
GO

CREATE TABLE dbo.TblTrnTSKTaskCommentDraft (
    TaskCommentDraftId    dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentDraft_TaskCommentDraftId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    UserUo                dbo.Uno NOT NULL,
    DraftEn               NVARCHAR(MAX) NULL,
    DraftAr               NVARCHAR(MAX) NULL,
    LastAutoSavedOn    DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentDraft_LastAutoSavedOn DEFAULT (SYSUTCDATETIME()),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentDraft_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentDraft_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentDraft_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskCommentDraft_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskCommentDraft_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskCommentDraft_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskCommentDraft_UQ
ON dbo.TblTrnTSKTaskCommentDraft (TenantUno, TaskUno, UserUo)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTaskCommentDraft_User_LastAutoSaved
ON dbo.TblTrnTSKTaskCommentDraft (TenantUno, UserUo, LastAutoSavedOn DESC)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskCommentMention (
    TaskCommentMentionId  dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentMention_TaskCommentMentionId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskCommentId         dbo.Uno NOT NULL,
    MentionedUserUo       dbo.Uno NOT NULL,
    MentionToken          VARCHAR(120) NULL,
    IsNotified            BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentMention_IsNotified DEFAULT (0),
    NotifiedOnUtc         DATETIME2(3) NULL,
    IsRead                BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentMention_IsRead DEFAULT (0),
    ReadOnUtc             DATETIME2(3) NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentMention_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentMention_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskCommentMention_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskCommentMention_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskCommentMention_TaskComment FOREIGN KEY (TaskCommentId) REFERENCES dbo.TblTrnTSKTaskComment (TaskCommentId),
    CONSTRAINT FK_TblTrnTSKTaskCommentMention_MentionedUser FOREIGN KEY (MentionedUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskCommentMention_UQ
ON dbo.TblTrnTSKTaskCommentMention (TenantUno, TaskCommentId, MentionedUserUo)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKTaskCommentMention_User_Inbox
ON dbo.TblTrnTSKTaskCommentMention (TenantUno, MentionedUserUo, IsRead, EnteredOn DESC)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskAttachment (
    TaskAttachmentId      dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_TaskAttachmentId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    FileNameOriginal      NVARCHAR(255) NOT NULL,
    FileExtension         VARCHAR(20) NULL,
    MimeType              VARCHAR(120) NULL,
    FileSizeBytes         BIGINT NULL,
    StorageProvider       VARCHAR(50) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_StorageProvider DEFAULT ('DB'),
    StoragePath           NVARCHAR(500) NULL,
    FileHashSha256        CHAR(64) NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskAttachment_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKTaskAttachment_FileSize CHECK (FileSizeBytes IS NULL OR FileSizeBytes <= 10485760),
    CONSTRAINT CK_TblTrnTSKTaskAttachment_FileExtension CHECK (
        FileExtension IS NULL
        OR UPPER(FileExtension) IN ('SVG', '.SVG', 'JPG', '.JPG', 'JPEG', '.JPEG', 'PNG', '.PNG', 'PDF', '.PDF', 'DOC', '.DOC')
    ),
    CONSTRAINT FK_TblTrnTSKTaskAttachment_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskAttachment_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskAttachment_CreatedBy FOREIGN KEY (EnteredBy) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskAttachment_Task
ON dbo.TblTrnTSKTaskAttachment (TenantUno, TaskUno, EnteredOn)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskTimeLog (
    TaskTimeLogId         dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_TaskTimeLogId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    UserUo                dbo.Uno NOT NULL,
    WorkDate              DATE NOT NULL,
    StartUtc              DATETIME2(3) NULL,
    EndUtc                DATETIME2(3) NULL,
    DurationMinutes       INT NOT NULL,
    NotesEn               NVARCHAR(1000) NULL,
    NotesAr               NVARCHAR(1000) NULL,
    IsBillable            BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_IsBillable DEFAULT (0),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskTimeLog_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKTaskTimeLog_DurationMinutes CHECK (DurationMinutes > 0),
    CONSTRAINT FK_TblTrnTSKTaskTimeLog_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskTimeLog_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskTimeLog_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskTimeLog_User_WorkDate
ON dbo.TblTrnTSKTaskTimeLog (TenantUno, UserUo, WorkDate)
INCLUDE (TaskUno, DurationMinutes)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskStatusHistory (
    TaskStatusHistoryId   dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_TaskStatusHistoryId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    FromStatusId          dbo.Uno NULL,
    ToStatusId            dbo.Uno NOT NULL,
    ChangeReasonEn        NVARCHAR(1000) NULL,
    ChangeReasonAr        NVARCHAR(1000) NULL,
    ChangedByUserUo       dbo.Uno NULL,
    ChangedOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_ChangedOnUtc DEFAULT (SYSUTCDATETIME()),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskStatusHistory_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_FromStatus FOREIGN KEY (FromStatusId) REFERENCES dbo.TblMstTSKStatus (StatusId),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_ToStatus FOREIGN KEY (ToStatusId) REFERENCES dbo.TblMstTSKStatus (StatusId),
    CONSTRAINT FK_TblTrnTSKTaskStatusHistory_ChangedBy FOREIGN KEY (ChangedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskStatusHistory_Task_ChangedOn
ON dbo.TblTrnTSKTaskStatusHistory (TenantUno, TaskUno, ChangedOnUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskHistory (
    TaskHistoryId          dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskHistory_TaskHistoryId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    TaskUno                 dbo.Uno NOT NULL,
    EventTypeCode          VARCHAR(40) NOT NULL, -- Created/Updated/Reassigned/Commented/AttachmentAdded/SubtaskUpdated/Archived
    FieldNameCode          VARCHAR(40) NULL,     -- Status/Priority/DueDate/Progress/Description etc.
    OldValueEn             NVARCHAR(1000) NULL,
    OldValueAr             NVARCHAR(1000) NULL,
    NewValueEn             NVARCHAR(1000) NULL,
    NewValueAr             NVARCHAR(1000) NULL,
    EventNoteEn            NVARCHAR(1000) NULL,
    EventNoteAr            NVARCHAR(1000) NULL,
    ChangedByUserUo        dbo.Uno NULL,
    ChangedOnUtc           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskHistory_ChangedOnUtc DEFAULT (SYSUTCDATETIME()),
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskHistory_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskHistory_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskHistory_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskHistory_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskHistory_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskHistory_ChangedBy FOREIGN KEY (ChangedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskHistory_Task_ChangedOn
ON dbo.TblTrnTSKTaskHistory (TenantUno, TaskUno, ChangedOnUtc)
INCLUDE (EventTypeCode, FieldNameCode, NewValueEn, ChangedByUserUo)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskDependency (
    TaskDependencyId      dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_TaskDependencyId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    DependsOnTaskUno       dbo.Uno NOT NULL,
    DependencyTypeCode    VARCHAR(20) NOT NULL, -- FS, SS, FF, SF
    LagMinutes            INT NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_LagMinutes DEFAULT (0),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskDependency_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskDependency_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskDependency_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskDependency_DependsOn FOREIGN KEY (DependsOnTaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT CK_TblTrnTSKTaskDependency_NoSelf CHECK (TaskUno <> DependsOnTaskUno)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskDependency_UQ
ON dbo.TblTrnTSKTaskDependency (TenantUno, TaskUno, DependsOnTaskUno)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskTagMap (
    TaskTagMapId          dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskTagMap_TaskTagMapId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    TagId                 dbo.Uno NOT NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTagMap_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskTagMap_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskTagMap_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskTagMap_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskTagMap_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskTagMap_Tag FOREIGN KEY (TagId) REFERENCES dbo.TblMstTSKTag (TagId)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskTagMap_UQ
ON dbo.TblTrnTSKTaskTagMap (TenantUno, TaskUno, TagId)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskWatcher (
    TaskWatcherId         dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_TaskWatcherId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    UserUo                dbo.Uno NOT NULL,
    NotifyByEmail         BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_NotifyByEmail DEFAULT (1),
    NotifyInApp           BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_NotifyInApp DEFAULT (1),
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskWatcher_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskWatcher_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskWatcher_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskWatcher_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKTaskWatcher_UQ
ON dbo.TblTrnTSKTaskWatcher (TenantUno, TaskUno, UserUo)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskApproval (
    TaskApprovalId        dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskApproval_TaskApprovalId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NOT NULL,
    ApproverUserUo        dbo.Uno NOT NULL,
    ApprovalStatusCode    VARCHAR(20) NOT NULL, -- Pending/Approved/Rejected
    ApprovalRemarksEn     NVARCHAR(1000) NULL,
    ApprovalRemarksAr     NVARCHAR(1000) NULL,
    DecisionOnUtc         DATETIME2(3) NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskApproval_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskApproval_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskApproval_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKTaskApproval_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskApproval_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskApproval_Approver FOREIGN KEY (ApproverUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskApproval_Approver_Status
ON dbo.TblTrnTSKTaskApproval (TenantUno, ApproverUserUo, ApprovalStatusCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKNotification (
    NotificationId        dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKNotification_NotificationId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno              dbo.Uno NOT NULL,
    UserUo                dbo.Uno NOT NULL,
    TaskUno                dbo.Uno NULL,
    NotificationTypeCode  VARCHAR(30) NOT NULL,
    TitleEn               NVARCHAR(250) NOT NULL,
    TitleAr               NVARCHAR(250) NULL,
    MessageEn             NVARCHAR(1000) NULL,
    MessageAr             NVARCHAR(1000) NULL,
    IsRead                BIT NOT NULL CONSTRAINT DF_TblTrnTSKNotification_IsRead DEFAULT (0),
    ReadOnUtc             DATETIME2(3) NULL,
    IsActive              TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKNotification_IsActive DEFAULT (1),
    IsDeleted             BIT NOT NULL CONSTRAINT DF_TblTrnTSKNotification_IsDeleted DEFAULT (0),
    EnteredOn          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKNotification_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy       dbo.Uno NULL,
    ModifiedOn         DATETIME2(3) NULL,
    ModifiedBy      dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKNotification_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKNotification_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKNotification_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno)
);
GO
CREATE INDEX IX_TblTrnTSKNotification_User_IsRead_CreatedOn
ON dbo.TblTrnTSKNotification (TenantUno, UserUo, IsRead, EnteredOn)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKProjectMember (
    ProjectMemberId        dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKProjectMember_ProjectMemberId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    ProjectId              dbo.Uno NOT NULL,
    UserUo                 dbo.Uno NOT NULL,
    MemberRoleCode         VARCHAR(30) NULL,
    AllocationPercent      DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblTrnTSKProjectMember_AllocationPercent DEFAULT (100),
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKProjectMember_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKProjectMember_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKProjectMember_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKProjectMember_AllocationPercent CHECK (AllocationPercent > 0 AND AllocationPercent <= 100),
    CONSTRAINT FK_TblTrnTSKProjectMember_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKProjectMember_Project FOREIGN KEY (ProjectId) REFERENCES dbo.TblMstTSKProject (ProjectId),
    CONSTRAINT FK_TblTrnTSKProjectMember_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKProjectMember_UQ
ON dbo.TblTrnTSKProjectMember (TenantUno, ProjectId, UserUo)
WHERE IsDeleted = 0;
GO
CREATE INDEX IX_TblTrnTSKProjectMember_User
ON dbo.TblTrnTSKProjectMember (TenantUno, UserUo, ProjectId)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKTaskReassignment (
    TaskReassignmentId     dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKTaskReassignment_TaskReassignmentId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    TaskUno                 dbo.Uno NOT NULL,
    FromAssigneeUserUo     dbo.Uno NULL,
    ToAssigneeUserUo       dbo.Uno NOT NULL,
    FromAssigneeLoadPercent DECIMAL(5,2) NULL,
    ToAssigneeLoadPercent   DECIMAL(5,2) NULL,
    ToAssigneeAvailabilityStatusCode VARCHAR(20) NULL, -- Available/Normal/High/Overloaded
    ReasonEn               NVARCHAR(1000) NULL,
    ReasonAr               NVARCHAR(1000) NULL,
    ReassignedByUserUo     dbo.Uno NULL,
    ReassignedOnUtc        DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskReassignment_ReassignedOnUtc DEFAULT (SYSUTCDATETIME()),
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKTaskReassignment_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKTaskReassignment_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKTaskReassignment_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKTaskReassignment_NoSelf CHECK (FromAssigneeUserUo IS NULL OR FromAssigneeUserUo <> ToAssigneeUserUo),
    CONSTRAINT CK_TblTrnTSKTaskReassignment_ReasonRequired CHECK (
        LEN(LTRIM(RTRIM(ISNULL(ReasonEn, N'')))) > 0
        OR LEN(LTRIM(RTRIM(ISNULL(ReasonAr, N'')))) > 0
    ),
    CONSTRAINT CK_TblTrnTSKTaskReassignment_FromLoadPct CHECK (FromAssigneeLoadPercent IS NULL OR (FromAssigneeLoadPercent >= 0 AND FromAssigneeLoadPercent <= 100)),
    CONSTRAINT CK_TblTrnTSKTaskReassignment_ToLoadPct CHECK (ToAssigneeLoadPercent IS NULL OR (ToAssigneeLoadPercent >= 0 AND ToAssigneeLoadPercent <= 100)),
    CONSTRAINT FK_TblTrnTSKTaskReassignment_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKTaskReassignment_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKTaskReassignment_FromAssignee FOREIGN KEY (FromAssigneeUserUo) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKTaskReassignment_ToAssignee FOREIGN KEY (ToAssigneeUserUo) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKTaskReassignment_ReassignedBy FOREIGN KEY (ReassignedByUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKTaskReassignment_Task
ON dbo.TblTrnTSKTaskReassignment (TenantUno, TaskUno, ReassignedOnUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKActivityFeed (
    ActivityId             dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKActivityFeed_ActivityId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    ActivityTypeCode       VARCHAR(40) NOT NULL,
    EntityTypeCode         VARCHAR(40) NOT NULL,
    EntityId               dbo.Uno NULL,
    TaskUno                 dbo.Uno NULL,
    ProjectId              dbo.Uno NULL,
    ActorUserUo            dbo.Uno NULL,
    TargetUserUo           dbo.Uno NULL,
    ActivityTextEn         NVARCHAR(1000) NOT NULL,
    ActivityTextAr         NVARCHAR(1000) NULL,
    MetadataJson           NVARCHAR(MAX) NULL,
    OccurredOnUtc          DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKActivityFeed_OccurredOnUtc DEFAULT (SYSUTCDATETIME()),
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKActivityFeed_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKActivityFeed_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKActivityFeed_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKActivityFeed_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKActivityFeed_Task FOREIGN KEY (TaskUno) REFERENCES dbo.TblTrnTSKTask (TaskUno),
    CONSTRAINT FK_TblTrnTSKActivityFeed_Project FOREIGN KEY (ProjectId) REFERENCES dbo.TblMstTSKProject (ProjectId),
    CONSTRAINT FK_TblTrnTSKActivityFeed_Actor FOREIGN KEY (ActorUserUo) REFERENCES dbo.TblMstTSKUser (UserUo),
    CONSTRAINT FK_TblTrnTSKActivityFeed_Target FOREIGN KEY (TargetUserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKActivityFeed_Tenant_OccurredOn
ON dbo.TblTrnTSKActivityFeed (TenantUno, OccurredOnUtc)
INCLUDE (ActivityTypeCode, TaskUno, ProjectId, ActorUserUo, ActivityTextEn)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKMemberPresenceLog (
    PresenceLogId          dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKMemberPresenceLog_PresenceLogId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    UserUo                 dbo.Uno NOT NULL,
    PresenceStatusCode     VARCHAR(15) NOT NULL, -- Online/Idle/Offline
    SessionStartUtc        DATETIME2(3) NOT NULL,
    SessionEndUtc          DATETIME2(3) NULL,
    LastHeartbeatUtc       DATETIME2(3) NULL,
    SourceTypeCode         VARCHAR(20) NULL,
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKMemberPresenceLog_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKMemberPresenceLog_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKMemberPresenceLog_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT FK_TblTrnTSKMemberPresenceLog_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKMemberPresenceLog_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE INDEX IX_TblTrnTSKMemberPresenceLog_User_Start
ON dbo.TblTrnTSKMemberPresenceLog (TenantUno, UserUo, SessionStartUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKDashboardKpiSnapshot (
    DashboardKpiSnapshotId dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_DashboardKpiSnapshotId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    SnapshotDateUtc        DATE NOT NULL,
    PeriodTypeCode         VARCHAR(20) NOT NULL, -- Last7Days/Last30Days/ThisQuarter
    TeamScopeCode          VARCHAR(30) NOT NULL, -- AllTeams/Development/Operations/Design
    TotalTasks             INT NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_TotalTasks DEFAULT (0),
    CompletedTasks         INT NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_CompletedTasks DEFAULT (0),
    CompletionRatePercent  DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_CompletionRatePercent DEFAULT (0),
    OverdueTasks           INT NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_OverdueTasks DEFAULT (0),
    AvgCompletionDays      DECIMAL(8,2) NULL,
    ActiveMembers          INT NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_ActiveMembers DEFAULT (0),
    OnTimeDeliveryPercent  DECIMAL(5,2) NULL,
    TeamVelocityPerWeek    DECIMAL(8,2) NULL,
    AvgLoadPercent         DECIMAL(5,2) NULL,
    ReassignedTasksCount   INT NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_ReassignedTasksCount DEFAULT (0),
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKDashboardKpiSnapshot_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKDashboardKpiSnapshot_CompletionRatePercent CHECK (CompletionRatePercent >= 0 AND CompletionRatePercent <= 100),
    CONSTRAINT FK_TblTrnTSKDashboardKpiSnapshot_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKDashboardKpiSnapshot_UQ
ON dbo.TblTrnTSKDashboardKpiSnapshot (TenantUno, SnapshotDateUtc, PeriodTypeCode, TeamScopeCode)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKPortfolioKpiSnapshot (
    PortfolioKpiSnapshotId dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_PortfolioKpiSnapshotId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    ProjectId              dbo.Uno NOT NULL,
    SnapshotDateUtc        DATE NOT NULL,
    HealthStatusCode       VARCHAR(20) NOT NULL, -- OnTrack/AtRisk/OffTrack
    ProgressPercent        DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_ProgressPercent DEFAULT (0),
    TotalTasks             INT NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_TotalTasks DEFAULT (0),
    ActiveTasks            INT NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_ActiveTasks DEFAULT (0),
    DoneTasks              INT NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_DoneTasks DEFAULT (0),
    OverdueTasks           INT NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_OverdueTasks DEFAULT (0),
    RiskNoteEn             NVARCHAR(1000) NULL,
    RiskNoteAr             NVARCHAR(1000) NULL,
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKPortfolioKpiSnapshot_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKPortfolioKpiSnapshot_ProgressPercent CHECK (ProgressPercent >= 0 AND ProgressPercent <= 100),
    CONSTRAINT FK_TblTrnTSKPortfolioKpiSnapshot_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKPortfolioKpiSnapshot_Project FOREIGN KEY (ProjectId) REFERENCES dbo.TblMstTSKProject (ProjectId)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKPortfolioKpiSnapshot_UQ
ON dbo.TblTrnTSKPortfolioKpiSnapshot (TenantUno, ProjectId, SnapshotDateUtc)
WHERE IsDeleted = 0;
GO

CREATE TABLE dbo.TblTrnTSKMemberKpiSnapshot (
    MemberKpiSnapshotId    dbo.Uno  NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_MemberKpiSnapshotId DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    TenantUno               dbo.Uno NOT NULL,
    UserUo                 dbo.Uno NOT NULL,
    SnapshotDateUtc        DATE NOT NULL,
    WorkloadPercent        DECIMAL(5,2) NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_WorkloadPercent DEFAULT (0),
    AvailabilityStatusCode VARCHAR(20) NULL, -- Overloaded/High/Normal/Available/Low
    AssignedTasks          INT NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_AssignedTasks DEFAULT (0),
    CompletedTasks         INT NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_CompletedTasks DEFAULT (0),
    OverdueTasks           INT NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_OverdueTasks DEFAULT (0),
    AvgCompletionDays      DECIMAL(8,2) NULL,
    BadgeCode              VARCHAR(30) NULL, -- TopPerformer/HighLoad
    IsActive               TINYINT NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_IsActive DEFAULT (1),
    IsDeleted              BIT NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_IsDeleted DEFAULT (0),
    EnteredOn           DATETIME2(3) NOT NULL CONSTRAINT DF_TblTrnTSKMemberKpiSnapshot_EnteredOn DEFAULT (SYSUTCDATETIME()),
    EnteredBy        dbo.Uno NULL,
    ModifiedOn          DATETIME2(3) NULL,
    ModifiedBy       dbo.Uno NULL,
    DeletedOn           DATETIME2(3) NULL,
    DeletedBy           dbo.Uno NULL,
    RowVer                 ROWVERSION NOT NULL,
    CONSTRAINT CK_TblTrnTSKMemberKpiSnapshot_WorkloadPercent CHECK (WorkloadPercent >= 0 AND WorkloadPercent <= 100),
    CONSTRAINT FK_TblTrnTSKMemberKpiSnapshot_Tenant FOREIGN KEY (TenantUno) REFERENCES dbo.TblMstTSKTenant (TenantUno),
    CONSTRAINT FK_TblTrnTSKMemberKpiSnapshot_User FOREIGN KEY (UserUo) REFERENCES dbo.TblMstTSKUser (UserUo)
);
GO
CREATE UNIQUE INDEX UX_TblTrnTSKMemberKpiSnapshot_UQ
ON dbo.TblTrnTSKMemberKpiSnapshot (TenantUno, UserUo, SnapshotDateUtc)
WHERE IsDeleted = 0;
GO

/* =========================================================
   END OF SCHEMA
   ========================================================= */
