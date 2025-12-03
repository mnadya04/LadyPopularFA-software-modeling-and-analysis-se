USE LadyPopularDB;
GO

IF OBJECT_ID(N'dbo.usp_MakePurchase', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_MakePurchase;
GO

CREATE PROCEDURE dbo.usp_MakePurchase
    @UserId       INT,
    @VIPPackageId INT,
    @Currency     VARCHAR(30) = 'EUR',
    @PaymentMethod VARCHAR(30) = 'Card'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @price DECIMAL(10,2),
                @offer VARCHAR(100);

        SELECT
            @price = Price,
            @offer = Offer
        FROM dbo.VIPPackage
        WHERE VIPPackageId = @VIPPackageId;

        IF @price IS NULL
        BEGIN
            RAISERROR('VIPPackage not found.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END;

        INSERT INTO dbo.Purchase (Currency, PaymentMethod, UserId, VIPPackageId)
        VALUES (@Currency, @PaymentMethod, @UserId, @VIPPackageId);

        DECLARE @emeraldDelta INT = 0,
                @diamondDelta INT = 0;

        IF @offer LIKE '%Emerald%'
            SET @emeraldDelta = CAST(@price * 10 AS INT);
        ELSE IF @offer LIKE '%Diamond%'
            SET @diamondDelta = CAST(@price * 10 AS INT);
        ELSE
            SET @emeraldDelta = CAST(@price * 5 AS INT);

        UPDATE dbo.[User]
        SET EmeraldBalance = EmeraldBalance + @emeraldDelta,
            DiamondBalance = DiamondBalance + @diamondDelta
        WHERE UserId = @UserId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('usp_MakePurchase failed: %s', 16, 1, @msg);
    END CATCH
END;
GO

-- Test examples:
-- EXEC dbo.usp_MakePurchase 1, 1;
-- EXEC dbo.usp_MakePurchase 2, 2, 'USD', 'PayPal';
