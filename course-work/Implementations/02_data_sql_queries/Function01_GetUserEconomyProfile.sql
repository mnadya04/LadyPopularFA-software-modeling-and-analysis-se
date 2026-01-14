USE LadyPopularDB; 
GO
CREATE FUNCTION dbo.ufn_GetUserEconomyProfile
(
    @UserId INT
)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE 
        @emeralds INT,
        @diamonds INT,
        @profile VARCHAR(30);

    SELECT 
        @emeralds = ISNULL(EmeraldBalance, 0),
        @diamonds = ISNULL(DiamondBalance, 0)
    FROM dbo.[User]
    WHERE UserId = @UserId;

    SET @profile =
        CASE
            WHEN @diamonds >= 100 THEN 'Premium Collector'
            WHEN @emeralds >= 1000 THEN 'Hardcore Player'
            WHEN @emeralds >= 300 THEN 'Active Player'
            ELSE 'Casual Player'
        END;

    RETURN @profile;
END;
GO

/*
TEST:
Returns economy profile for all users.

SELECT 
    UserId,
    Username,
    EmeraldBalance,
    DiamondBalance,
    dbo.ufn_GetUserEconomyProfile(UserId) AS EconomyProfile
FROM dbo.[User];
*/