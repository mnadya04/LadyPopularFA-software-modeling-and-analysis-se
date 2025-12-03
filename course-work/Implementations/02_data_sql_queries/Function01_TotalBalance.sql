USE LadyPopularDB;
GO

IF OBJECT_ID(N'dbo.ufn_GetTotalBalance', N'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_GetTotalBalance;
GO

CREATE FUNCTION dbo.ufn_GetTotalBalance
(
    @UserId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;

    SELECT @total =
        ISNULL(EmeraldBalance, 0) + ISNULL(DiamondBalance, 0)
    FROM dbo.[User]
    WHERE UserId = @UserId;

    RETURN ISNULL(@total, 0);
END;
GO

-- Test:
-- SELECT UserId, Username, dbo.ufn_GetTotalBalance(UserId) AS TotalBalance FROM dbo.[User];
