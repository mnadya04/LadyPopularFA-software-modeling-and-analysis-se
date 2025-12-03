USE LadyPopularDB;
GO

IF OBJECT_ID(N'dbo.trg_Donation_UpdateClubSafe', N'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Donation_UpdateClubSafe;
GO

CREATE TRIGGER dbo.trg_Donation_UpdateClubSafe
ON dbo.Donation
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ins AS (
        SELECT
            ClubSafeId,
            SUM(EmeraldAmount) AS EmeraldIns,
            SUM(DiamondAmount) AS DiamondIns
        FROM inserted
        GROUP BY ClubSafeId
    ),
    del AS (
        SELECT
            ClubSafeId,
            SUM(EmeraldAmount) AS EmeraldDel,
            SUM(DiamondAmount) AS DiamondDel
        FROM deleted
        GROUP BY ClubSafeId
    ),
    delta AS (
        SELECT
            COALESCE(i.ClubSafeId, d.ClubSafeId) AS ClubSafeId,
            ISNULL(i.EmeraldIns,0) - ISNULL(d.EmeraldDel,0) AS DeltaEmerald,
            ISNULL(i.DiamondIns,0) - ISNULL(d.DiamondDel,0) AS DeltaDiamond
        FROM ins i
        FULL OUTER JOIN del d
            ON i.ClubSafeId = d.ClubSafeId
    )
    UPDATE cs
    SET EmeraldBalance = EmeraldBalance + d.DeltaEmerald,
        DiamondBalance = DiamondBalance + d.DeltaDiamond
    FROM dbo.ClubSafe cs
    JOIN delta d ON cs.ClubSafeId = d.ClubSafeId;
END;
GO

-- Tests:
-- INSERT INTO Donation (EmeraldAmount, DiamondAmount, UserId, ClubSafeId) VALUES (5, 1, 1, 1);
-- UPDATE Donation SET EmeraldAmount = 10 WHERE DonationId = 1;
-- DELETE FROM Donation WHERE DonationId = 1;
