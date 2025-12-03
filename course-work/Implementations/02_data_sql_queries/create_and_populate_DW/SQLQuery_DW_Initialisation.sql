USE LadyPopularDB;
GO

/* ======================================
   DIMENSIONS
   ====================================== */

------------------------------------------
-- 1) DimDate
------------------------------------------
CREATE TABLE DimDate (
    DateKey      INT        PRIMARY KEY,   -- напр. 20241104
    [Date]       DATE       NOT NULL,
    [Year]       INT        NOT NULL,
    [Month]      INT        NOT NULL,
    [Day]        INT        NOT NULL,
    MonthName    VARCHAR(20),
    [Quarter]    INT
);
GO


------------------------------------------
-- 2) DimLadyClub
------------------------------------------
CREATE TABLE DimLadyClub (
    LadyClubKey     INT IDENTITY(1,1) PRIMARY KEY,
    LadyClubId      INT        NOT NULL,
    [Name]          VARCHAR(50),
    Prestige        INT,
    DateCreatedKey  INT,
    FOREIGN KEY (DateCreatedKey) REFERENCES DimDate(DateKey)
);
GO


------------------------------------------
-- 3) DimUser
------------------------------------------
CREATE TABLE DimUser (
    UserKey          INT IDENTITY(1,1) PRIMARY KEY,
    UserId           INT         NOT NULL,
    Username         VARCHAR(50),
    Email            VARCHAR(100),
    EmeraldBalance   INT,
    DiamondBalance   INT,
    ExperiencePoints INT,
    IsPresident      BIT,
    LadyClubKey      INT,
    FOREIGN KEY (LadyClubKey) REFERENCES DimLadyClub(LadyClubKey)
);
GO


------------------------------------------
-- 4) DimVIPPackage
------------------------------------------
CREATE TABLE DimVIPPackage (
    VIPPackageKey  INT IDENTITY(1,1) PRIMARY KEY,
    VIPPackageId   INT         NOT NULL,
    Offer          VARCHAR(100),
    Price          DECIMAL(10,2),
    AddedDateKey   INT,
    EndDateKey     INT,
    FOREIGN KEY (AddedDateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (EndDateKey)   REFERENCES DimDate(DateKey)
);
GO


------------------------------------------
-- 5) DimEvent
------------------------------------------
CREATE TABLE DimEvent (
    EventKey        INT IDENTITY(1,1) PRIMARY KEY,
    EventId         INT         NOT NULL,
    NameTheme       VARCHAR(100),
    ReleaseDateKey  INT,
    DaysActive      INT,
    HasBeenPlayed   BIT,
    LadyUserKey     INT,
    FOREIGN KEY (ReleaseDateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (LadyUserKey)    REFERENCES DimUser(UserKey)
);
GO


------------------------------------------
-- 6) DimClothing
------------------------------------------
CREATE TABLE DimClothing (
    ClothingKey INT IDENTITY(1,1) PRIMARY KEY,
    ClothingId  INT         NOT NULL,
    [Type]      VARCHAR(50),
    Colour      VARCHAR(50),
    IsPose      BIT,
    IsAnimated  BIT
);
GO



/* ======================================
   FACT TABLES
   ====================================== */

------------------------------------------
-- FactPurchase
------------------------------------------
CREATE TABLE FactPurchase (
    PurchaseKey     INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseId      INT         NOT NULL,
    DateKey         INT         NOT NULL,
    UserKey         INT         NOT NULL,
    VIPPackageKey   INT         NOT NULL,
    Amount          DECIMAL(10,2),
    Currency        VARCHAR(30),
    PaymentMethod   VARCHAR(30),

    FOREIGN KEY (DateKey)       REFERENCES DimDate(DateKey),
    FOREIGN KEY (UserKey)       REFERENCES DimUser(UserKey),
    FOREIGN KEY (VIPPackageKey) REFERENCES DimVIPPackage(VIPPackageKey)
);
GO


------------------------------------------
-- FactDonation
------------------------------------------
CREATE TABLE FactDonation (
    DonationKey     INT IDENTITY(1,1) PRIMARY KEY,
    DonationId      INT         NOT NULL,
    DateKey         INT         NOT NULL,
    UserKey         INT         NOT NULL,
    LadyClubKey     INT         NOT NULL,
    EmeraldAmount   INT,
    DiamondAmount   INT,

    FOREIGN KEY (DateKey)     REFERENCES DimDate(DateKey),
    FOREIGN KEY (UserKey)     REFERENCES DimUser(UserKey),
    FOREIGN KEY (LadyClubKey) REFERENCES DimLadyClub(LadyClubKey)
);
GO


------------------------------------------
-- FactClothing
------------------------------------------
CREATE TABLE FactClothing (
    ClothingFactKey INT IDENTITY(1,1) PRIMARY KEY,
    ClothingId      INT         NOT NULL,
    UserKey         INT         NOT NULL,
    ClothingKey     INT         NOT NULL,
    EventKey        INT         NULL,
    DateKey         INT         NOT NULL,
    IsFromEvent     BIT,

    FOREIGN KEY (UserKey)     REFERENCES DimUser(UserKey),
    FOREIGN KEY (ClothingKey) REFERENCES DimClothing(ClothingKey),
    FOREIGN KEY (EventKey)    REFERENCES DimEvent(EventKey),
    FOREIGN KEY (DateKey)     REFERENCES DimDate(DateKey)
);
GO
