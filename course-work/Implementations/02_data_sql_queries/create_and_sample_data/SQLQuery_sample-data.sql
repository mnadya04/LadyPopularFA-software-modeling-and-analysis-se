USE LadyPopularDB;
GO

------------------------------------------------------------
-- 1. Lady Clubs
------------------------------------------------------------
INSERT INTO LadyClub (Name, Description, Prestige)
VALUES 
('Glam Queens', 'Elite fashion club focused on style competitions.', 800),
('Star Angels', 'A friendly club that helps new players grow.', 600);

------------------------------------------------------------
-- 2. ClubSafe (1:1 с LadyClub)
------------------------------------------------------------
INSERT INTO ClubSafe (LadyClubId, EmeraldBalance, DiamondBalance)
VALUES 
(1, 200, 50),  -- Glam Queens safe
(2, 100, 20);  -- Star Angels safe


------------------------------------------------------------
-- 3. Users
------------------------------------------------------------
INSERT INTO [User] 
(Username, Email, Password, EmeraldBalance, DiamondBalance, ExperiencePoints, IsPresident, LadyClubId)
VALUES
('LadyA', 'ladyA@example.com', 'PassA123!', 50, 10, 1200, 1, 1), -- President of Glam Queens
('LadyB', 'ladyB@example.com', 'PassB123!', 10, 2, 400, 0, 1),
('LadyC', 'ladyC@example.com', 'PassC123!', 0, 0, 100, 1, 2), -- President of Star Angels
('LadyD', 'ladyD@example.com', 'PassD123!', 5, 1, 250, 0, 2),
('SoloLady', 'solo@example.com', 'SoloPass!', 0, 0, 50, 0, NULL); -- No club

------------------------------------------------------------
-- 4. Events — each belongs to a specific Lady (LadyId)
------------------------------------------------------------
INSERT INTO [Event] (NameTheme, ReleaseDate, DaysActive, HasBeenPlayed, LadyId)
VALUES
('Summer Fiesta', '2024-06-01', 7, 1, 1),  -- LadyA event
('Royal Ball', '2024-07-10', 5, 0, 1),

('Neon Night', '2024-06-15', 10, 1, 2),   -- LadyB event

('Winter Magic', '2024-12-01', 14, 1, 3), -- LadyC event

('Disco Lights', '2024-05-20', 3, 1, 4),  -- LadyD event
('Fashion Runway', '2024-09-09', 6, 0, 5); -- SoloLady event


------------------------------------------------------------
-- 5. Clothing — belonging to a User, optionally tied to Event
------------------------------------------------------------

-- LadyA clothing
INSERT INTO Clothing (Type, DateAdded, Colour, IsPose, IsAnimated, UserId, EventId)
VALUES
('Dress', '2024-06-02', 'Red', 0, 0, 1, 1),        -- Won from Summer Fiesta
('Shoes', '2024-06-03', 'Gold', 0, 0, 1, NULL),    -- Bought, no event
('Hat', '2024-06-05', 'Black', 1, 0, 1, 2);        -- From Royal Ball

-- LadyB
INSERT INTO Clothing (Type, DateAdded, Colour, IsPose, IsAnimated, UserId, EventId)
VALUES
('Jacket', '2024-06-17', 'Blue', 0, 1, 2, 3),

('Top', '2024-06-18', 'Pink', 0, 0, 2, NULL);      -- Purchased normally

-- LadyC
INSERT INTO Clothing (Type, DateAdded, Colour, IsPose, IsAnimated, UserId, EventId)
VALUES
('Coat', '2024-12-02', 'White', 1, 0, 3, 4);

-- LadyD
INSERT INTO Clothing (Type, DateAdded, Colour, IsPose, IsAnimated, UserId, EventId)
VALUES
('Skirt', '2024-05-21', 'Purple', 0, 0, 4, 5);

-- SoloLady
INSERT INTO Clothing (Type, DateAdded, Colour, IsPose, IsAnimated, UserId, EventId)
VALUES
('Bag', '2024-09-10', 'Beige', 0, 0, 5, 6);


------------------------------------------------------------
-- 6. Donations
------------------------------------------------------------
INSERT INTO Donation (EmeraldAmount, DiamondAmount, UserId, ClubSafeId)
VALUES
(20, 5, 1, 1),  -- LadyA donated to Glam Queens
(10, 0, 2, 1),  -- LadyB donated
(0, 2, 3, 2),   -- LadyC donated to Star Angels
(5, 1, 4, 2);   -- LadyD donated


------------------------------------------------------------
-- 7. VIP Packages
------------------------------------------------------------
INSERT INTO VIPPackage (Offer, Price, AddedDate, EndDate)
VALUES
('Starter Pack', 4.99, '2024-01-01', '2024-12-31'),
('Emerald Booster', 9.99, '2024-02-01', '2024-12-31'),
('Diamond Bundle', 14.99, '2024-03-01', '2024-12-31');


------------------------------------------------------------
-- 8. Purchases
------------------------------------------------------------
INSERT INTO Purchase (Currency, PaymentMethod, UserId, VIPPackageId)
VALUES
('EUR', 'Card', 1, 1),   -- LadyA bought Starter Pack
('EUR', 'Card', 2, 1),   -- LadyB bought Starter Pack
('EUR', 'PayPal', 3, 2), -- LadyC bought Booster
('EUR', 'Card', 5, 3);   -- SoloLady bought Diamond Bundle

