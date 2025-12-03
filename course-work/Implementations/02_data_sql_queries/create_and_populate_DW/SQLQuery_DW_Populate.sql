USE LadyPopularDB;
GO

/* ============================================
   0. Изчистване на DW таблиците (по ред)
   ============================================ */

IF OBJECT_ID('FactClothing', 'U') IS NOT NULL DELETE FROM FactClothing;
IF OBJECT_ID('FactDonation', 'U') IS NOT NULL DELETE FROM FactDonation;
IF OBJECT_ID('FactPurchase', 'U') IS NOT NULL DELETE FROM FactPurchase;
GO

IF OBJECT_ID('DimEvent', 'U') IS NOT NULL DELETE FROM DimEvent;
IF OBJECT_ID('DimClothing', 'U') IS NOT NULL DELETE FROM DimClothing;
IF OBJECT_ID('DimVIPPackage', 'U') IS NOT NULL DELETE FROM DimVIPPackage;
IF OBJECT_ID('DimUser', 'U') IS NOT NULL DELETE FROM DimUser;
IF OBJECT_ID('DimLadyClub', 'U') IS NOT NULL DELETE FROM DimLadyClub;
IF OBJECT_ID('DimDate', 'U') IS NOT NULL DELETE FROM DimDate;
GO


/* ============================================
   1. DimDate  (FIX-нат вариант)
   ============================================ */

INSERT INTO DimDate (DateKey, [Date], [Year], [Month], [Day], MonthName, [Quarter])
SELECT DISTINCT
      CAST(CONVERT(CHAR(8), d.AllDate, 112) AS INT) AS DateKey,
      d.AllDate AS [Date],
      YEAR(d.AllDate) AS [Year],
      MONTH(d.AllDate) AS [Month],
      DAY(d.AllDate) AS [Day],
      DATENAME(MONTH, d.AllDate) AS MonthName,
      DATEPART(QUARTER, d.AllDate) AS [Quarter]
FROM (
      SELECT CAST(ReleaseDate AS DATE) AS AllDate FROM dbo.[Event]
      UNION
      SELECT CAST([Timestamp] AS DATE)      AS AllDate FROM dbo.Purchase
      UNION
      SELECT CAST([Date] AS DATE)           AS AllDate FROM dbo.Donation
      UNION
      SELECT CAST(DateAdded AS DATE)        AS AllDate FROM dbo.Clothing
      UNION
      SELECT CAST(AddedDate AS DATE)        AS AllDate FROM dbo.VIPPackage
      UNION
      SELECT CAST(EndDate AS DATE)          AS AllDate FROM dbo.VIPPackage
) d
WHERE d.AllDate IS NOT NULL;
GO

/* ============================================
   2. DimLadyClub
   ============================================ */
INSERT INTO DimLadyClub (LadyClubId, [Name], Prestige, DateCreatedKey)
SELECT 
    LC.LadyClubId,
    LC.[Name],
    LC.Prestige,
    CAST(CONVERT(CHAR(8), CAST(LC.DateCreated AS DATE), 112) AS INT) AS DateCreatedKey
FROM dbo.LadyClub LC;
GO

/* ============================================
   3. DimUser
   ============================================ */
INSERT INTO DimUser (UserId, Username, Email, EmeraldBalance, DiamondBalance, 
                     ExperiencePoints, IsPresident)
SELECT 
    U.UserId,
    U.Username,
    U.Email,
    U.EmeraldBalance,
    U.DiamondBalance,
    U.ExperiencePoints,
    U.IsPresident
FROM dbo.[User] U;
GO

/* ============================================
   4. DimVIPPackage
   ============================================ */
INSERT INTO DimVIPPackage (VIPPackageId, Offer, Price, AddedDateKey, EndDateKey)
SELECT
    V.VIPPackageId,
    V.Offer,
    V.Price,
    CAST(CONVERT(CHAR(8), CAST(V.AddedDate AS DATE), 112) AS INT) AS AddedDateKey,
    CAST(CONVERT(CHAR(8), CAST(V.EndDate   AS DATE), 112) AS INT) AS EndDateKey
FROM dbo.VIPPackage V;
GO

/* ============================================
   5. DimClothing
   ============================================ */
INSERT INTO DimClothing (ClothingId, [Type], Colour, IsPose, IsAnimated)
SELECT
    C.ClothingId,
    C.[Type],
    C.Colour,
    C.IsPose,
    C.IsAnimated
FROM dbo.Clothing C;
GO

/* ============================================
   6. DimEvent
   ============================================ */
INSERT INTO DimEvent (EventId, NameTheme, ReleaseDateKey, DaysActive, HasBeenPlayed, LadyUserKey)
SELECT
    E.EventId,
    E.NameTheme,
    CAST(CONVERT(CHAR(8), CAST(E.ReleaseDate AS DATE), 112) AS INT) AS ReleaseDateKey,
    E.DaysActive,
    E.HasBeenPlayed,
    UDim.UserKey
FROM dbo.[Event] E
LEFT JOIN DimUser UDim
    ON E.LadyId = UDim.UserId;
GO

/* ============================================
   7. FactPurchase
   ============================================ */
INSERT INTO FactPurchase (PurchaseId, DateKey, UserKey, VIPPackageKey, Amount, Currency, PaymentMethod)
SELECT
    P.PurchaseId,
    CAST(CONVERT(CHAR(8), CAST(P.[Timestamp] AS DATE), 112) AS INT) AS DateKey,
    UDim.UserKey,
    VDim.VIPPackageKey,
    V.Price AS Amount,
    P.Currency,
    P.PaymentMethod
FROM dbo.Purchase P
JOIN DimUser UDim
      ON P.UserId = UDim.UserId
JOIN DimVIPPackage VDim
      ON P.VIPPackageId = VDim.VIPPackageId
JOIN dbo.VIPPackage V
      ON P.VIPPackageId = V.VIPPackageId;
GO

/* ============================================
   8. FactDonation
   ============================================ */
INSERT INTO FactDonation (DonationId, DateKey, UserKey, LadyClubKey, EmeraldAmount, DiamondAmount)
SELECT 
    D.DonationId,
    CAST(CONVERT(CHAR(8), CAST(D.[Date] AS DATE), 112) AS INT) AS DateKey,
    UDim.UserKey,
    LCdim.LadyClubKey,
    D.EmeraldAmount,
    D.DiamondAmount
FROM dbo.Donation D
JOIN dbo.ClubSafe CS
      ON D.ClubSafeId = CS.ClubSafeId
JOIN DimLadyClub LCdim
      ON CS.LadyClubId = LCdim.LadyClubId
JOIN DimUser UDim
      ON D.UserId = UDim.UserId;
GO

/* ============================================
   9. FactClothing
   ============================================ */
INSERT INTO FactClothing (ClothingId, UserKey, ClothingKey, EventKey, DateKey, IsFromEvent)
SELECT
    C.ClothingId,
    UDim.UserKey,
    CDim.ClothingKey,
    EDim.EventKey,
    CAST(CONVERT(CHAR(8), CAST(C.DateAdded AS DATE), 112) AS INT) AS DateKey,
    CASE WHEN C.EventId IS NOT NULL THEN 1 ELSE 0 END AS IsFromEvent
FROM dbo.Clothing C
JOIN DimUser UDim
      ON C.UserId = UDim.UserId
JOIN DimClothing CDim
      ON C.ClothingId = CDim.ClothingId
LEFT JOIN DimEvent EDim
      ON C.EventId = EDim.EventId;
GO
