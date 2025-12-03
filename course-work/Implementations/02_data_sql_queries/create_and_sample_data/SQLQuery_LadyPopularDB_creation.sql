------------------------------------------------------------
-- DROP + CREATE database чисто (по желание)
------------------------------------------------------------
IF DB_ID(N'LadyPopularDB') IS NOT NULL
BEGIN
    ALTER DATABASE LadyPopularDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LadyPopularDB;
END;
GO

CREATE DATABASE LadyPopularDB;
GO

USE LadyPopularDB;
GO

------------------------------------------------------------
-- 1. LadyClub
------------------------------------------------------------
CREATE TABLE dbo.LadyClub
(
    LadyClubId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LadyClub PRIMARY KEY,
    [Name]       VARCHAR(50)  NOT NULL,
    [Description] VARCHAR(500) NULL,
    Prestige     INT          NOT NULL 
                   CONSTRAINT DF_LadyClub_Prestige DEFAULT 500
                   CONSTRAINT CK_LadyClub_Prestige CHECK (Prestige >= 0),
    DateCreated  DATETIME2    NOT NULL 
                   CONSTRAINT DF_LadyClub_DateCreated DEFAULT SYSUTCDATETIME()
);
GO

------------------------------------------------------------
-- 2. ClubSafe (1:1 с LadyClub)
------------------------------------------------------------
CREATE TABLE dbo.ClubSafe
(
    ClubSafeId      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ClubSafe PRIMARY KEY,
    LadyClubId      INT NOT NULL,
    EmeraldBalance  INT NOT NULL 
                      CONSTRAINT DF_ClubSafe_EmeraldBalance DEFAULT 0
                      CONSTRAINT CK_ClubSafe_EmeraldBalance CHECK (EmeraldBalance >= 0),
    DiamondBalance  INT NOT NULL 
                      CONSTRAINT DF_ClubSafe_DiamondBalance DEFAULT 0
                      CONSTRAINT CK_ClubSafe_DiamondBalance CHECK (DiamondBalance >= 0),

    CONSTRAINT UQ_ClubSafe_LadyClub UNIQUE (LadyClubId),
    CONSTRAINT FK_ClubSafe_LadyClub
        FOREIGN KEY (LadyClubId) REFERENCES dbo.LadyClub(LadyClubId)
        ON DELETE CASCADE
);
GO

------------------------------------------------------------
-- 3. User
------------------------------------------------------------
CREATE TABLE dbo.[User]
(
    UserId          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_User PRIMARY KEY,
    Username        VARCHAR(50)   NOT NULL,
    Email           VARCHAR(100)  NOT NULL,
    [Password]      NVARCHAR(255) NOT NULL,
    EmeraldBalance  INT           NOT NULL 
                     CONSTRAINT DF_User_EmeraldBalance DEFAULT 0
                     CONSTRAINT CK_User_EmeraldBalance CHECK (EmeraldBalance >= 0),
    DiamondBalance  INT           NOT NULL 
                     CONSTRAINT DF_User_DiamondBalance DEFAULT 0
                     CONSTRAINT CK_User_DiamondBalance CHECK (DiamondBalance >= 0),
    ExperiencePoints INT          NOT NULL 
                     CONSTRAINT DF_User_ExperiencePoints DEFAULT 0
                     CONSTRAINT CK_User_ExperiencePoints CHECK (ExperiencePoints >= 0),
    IsPresident     BIT           NOT NULL 
                     CONSTRAINT DF_User_IsPresident DEFAULT 0,
    LadyClubId      INT           NULL,

    CONSTRAINT UQ_User_Username UNIQUE (Username),
    CONSTRAINT UQ_User_Email    UNIQUE (Email),
    CONSTRAINT FK_User_LadyClub
        FOREIGN KEY (LadyClubId) REFERENCES dbo.LadyClub(LadyClubId)
        ON DELETE SET NULL
);
GO

-- по желание: един президент на клуб
CREATE UNIQUE INDEX UX_User_ClubPresident
ON dbo.[User](LadyClubId)
WHERE IsPresident = 1;
GO

------------------------------------------------------------
-- 4. Event (индивидуални за Lady)
------------------------------------------------------------
CREATE TABLE dbo.[Event]
(
    EventId       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Event PRIMARY KEY,
    NameTheme     VARCHAR(100) NOT NULL,
    ReleaseDate   DATETIME2    NULL,
    DaysActive    INT          NULL CONSTRAINT CK_Event_DaysActive CHECK (DaysActive IS NULL OR DaysActive >= 0),
    HasBeenPlayed BIT          NOT NULL CONSTRAINT DF_Event_HasBeenPlayed DEFAULT 0,
    LadyId        INT          NOT NULL,

    -- ВАЖНО: тук вече НЯМА ON DELETE CASCADE → така махаме multiple cascade paths
    CONSTRAINT FK_Event_Lady
        FOREIGN KEY (LadyId) REFERENCES dbo.[User](UserId)
);
GO

------------------------------------------------------------
-- 5. Clothing (1:N от User, 0..1:N от Event)
------------------------------------------------------------
CREATE TABLE dbo.Clothing
(
    ClothingId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Clothing PRIMARY KEY,
    [Type]      VARCHAR(50)  NOT NULL,
    DateAdded   DATETIME2    NOT NULL CONSTRAINT DF_Clothing_DateAdded DEFAULT SYSUTCDATETIME(),
    Colour      VARCHAR(50)  NULL,
    IsPose      BIT          NOT NULL CONSTRAINT DF_Clothing_IsPose DEFAULT 0,
    IsAnimated  BIT          NOT NULL CONSTRAINT DF_Clothing_IsAnimated DEFAULT 0,
    UserId      INT          NOT NULL,
    EventId     INT          NULL,

    CONSTRAINT FK_Clothing_User
        FOREIGN KEY (UserId) REFERENCES dbo.[User](UserId),
    CONSTRAINT FK_Clothing_Event
        FOREIGN KEY (EventId) REFERENCES dbo.[Event](EventId)
        ON DELETE SET NULL
);
GO

------------------------------------------------------------
-- 6. VIPPackage
------------------------------------------------------------
CREATE TABLE dbo.VIPPackage
(
    VIPPackageId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_VIPPackage PRIMARY KEY,
    Offer        VARCHAR(100) NOT NULL,
    Price        DECIMAL(10,2) NOT NULL CONSTRAINT CK_VIPPackage_Price CHECK (Price >= 0),
    AddedDate    DATETIME2    NOT NULL CONSTRAINT DF_VIPPackage_AddedDate DEFAULT SYSUTCDATETIME(),
    EndDate      DATETIME2    NOT NULL
);
GO

------------------------------------------------------------
-- 7. Purchase
------------------------------------------------------------
CREATE TABLE dbo.Purchase
(
    PurchaseId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Purchase PRIMARY KEY,
    [Timestamp]   DATETIME2    NOT NULL CONSTRAINT DF_Purchase_Timestamp DEFAULT SYSUTCDATETIME(),
    Currency      VARCHAR(30)  NOT NULL,
    PaymentMethod VARCHAR(30)  NOT NULL,
    UserId        INT          NOT NULL,
    VIPPackageId  INT          NOT NULL,

    CONSTRAINT FK_Purchase_User
        FOREIGN KEY (UserId) REFERENCES dbo.[User](UserId),
    CONSTRAINT FK_Purchase_VIPPackage
        FOREIGN KEY (VIPPackageId) REFERENCES dbo.VIPPackage(VIPPackageId)
);
GO

------------------------------------------------------------
-- 8. Donation (M:N User <-> ClubSafe)
------------------------------------------------------------
CREATE TABLE dbo.Donation
(
    DonationId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Donation PRIMARY KEY,
    EmeraldAmount INT NOT NULL CONSTRAINT DF_Donation_EmeraldAmount DEFAULT 0
                       CONSTRAINT CK_Donation_EmeraldAmount CHECK (EmeraldAmount >= 0),
    DiamondAmount INT NOT NULL CONSTRAINT DF_Donation_DiamondAmount DEFAULT 0
                       CONSTRAINT CK_Donation_DiamondAmount CHECK (DiamondAmount >= 0),
    [Date]        DATETIME2 NOT NULL CONSTRAINT DF_Donation_Date DEFAULT SYSUTCDATETIME(),
    UserId        INT NOT NULL,
    ClubSafeId    INT NOT NULL,

    CONSTRAINT FK_Donation_User
        FOREIGN KEY (UserId) REFERENCES dbo.[User](UserId)
        ON DELETE CASCADE,
    CONSTRAINT FK_Donation_ClubSafe
        FOREIGN KEY (ClubSafeId) REFERENCES dbo.ClubSafe(ClubSafeId)
        ON DELETE CASCADE
);
GO
