USE PhoneFitDB;
GO

CREATE TABLE [Role] (
	RoleID INT IDENTITY(1,1) NOT NULL,	   -- Role Identifier
	RoleName VARCHAR(50) UNIQUE NOT NULL,  -- Customer or Admin/Manager
	RoleDescription VARCHAR(250) NOT NULL, -- Explanation of their roles
	PRIMARY KEY(RoleID)
);

CREATE TABLE [UserAccount] (
	UserID INT IDENTITY(1,1) NOT NULL,					-- User identifier
	RoleID INT  NOT NULL,								-- links the account to a specific role
	UserEmail VARCHAR(100) UNIQUE NOT NULL,				-- used for registration and login
	UserPasswordHash VARCHAR(255) NOT NULL,				-- stores the hashed password
	UserFirstName VARCHAR(100) NOT NULL,				-- Users first name
	UserSurname VARCHAR(100) NOT NULL,					-- Users last name
	UserPhoneNumber VARCHAR(20),						-- optional contact number
	UserIsActive BIT  NOT NULL DEFAULT 1,				-- indicates whether the account may log in
	UserAccountCreated DATETIME NOT NULL DEFAULT GETDATE(),	-- account creation date and time
	PRIMARY KEY(UserID),
	FOREIGN KEY(RoleID) REFERENCES [Role](RoleID)
);

CREATE TABLE Brand (
	BrandID INT IDENTITY(1,1) UNIQUE NOT NULL,	-- Brand identifier
	BrandName VARCHAR(100) UNIQUE NOT NULL,		-- Name of the phone brand
	BrandDescription VARCHAR(500),				-- Short description of the phone brand (optional)
	BrandIsActive BIT NOT NULL DEFAULT 1,		-- If a certain brand is no longer available we can easily disable it
	PRIMARY KEY(BrandID)
);

CREATE TABLE PhoneModel (
	PhoneModelID INT IDENTITY(1,1) NOT NULL,		-- PhoneModel identifier
	BrandID INT NOT NULL,							-- Links the phone to a brand
	ModelName VARCHAR(150) NOT NULL,				-- smartphone model name
	OperatingSystem VARCHAR(50) NOT NULL,			-- Android, iOS etc.
	ReleaseYear INT,								-- the year the phone was released
	[Description] VARCHAR(MAX) NOT NULL,			-- description of the smartphone model
	ImagePath VARCHAR(MAX) NOT NULL,				-- a path to the phoneImage being displayed
	IsActive BIT NOT NULL DEFAULT 1,				-- controls whether or not to display the smartphone
	DateAdded DATETIME NOT NULL DEFAULT GETDATE(),	-- Date added to the catalogue
	UNIQUE(BrandID, ModelName),						-- brand model combo  should be unique
	PRIMARY KEY(PhoneModelID),
	FOREIGN KEY(BrandID) REFERENCES Brand(BrandID),

	-- Validation
	CHECK(ReleaseYear IS NULL OR ReleaseYear BETWEEN 1990 AND 2030)
);

CREATE TABLE PhoneVariant (
	VariantID INT IDENTITY(1,1) NOT NULL,		-- smartphone variant identifier
	PhoneModelID INT NOT NULL,					-- Links the variant to a smartphone 
	RAMGB INT NOT NULL,							-- RAM amount
	StorageGB INT NOT NULL,						-- Storage capacity
	Colour VARCHAR(50) NOT NULL,				-- Variant colour
	Price DECIMAL(12,2) NOT NULL,				-- current price
	StockQuantity INT NOT NULL DEFAULT 0,		-- current stock levels
	LowStockLevel INT NOT NULL DEFAULT 5,		-- threshhold that triggers a low stock warning
	IsActive BIT NOT NULL DEFAULT 1,			-- Indicates if that variant is active
	UNIQUE(PhoneModelID, RAMGB, StorageGB, Colour),	-- prevents inserting the same variant again
	PRIMARY KEY(VariantID),
	FOREIGN KEY(PhoneModelID) REFERENCES PhoneModel(PhoneModelID),

	-- Validation
	CHECK(RAMGB > 0),
	CHECK(StorageGB > 0),
	CHECK(Price >= 0),
	CHECK(StockQuantity >= 0),
	CHECK(LowStockLevel >= 0)
);

CREATE TABLE PhoneSpecification (
	SpecificationID INT IDENTITY(1,1) NOT NULL,	-- specification identifier
	PhoneModelID INT UNIQUE NOT NULL,			-- links specification to a phone model
	Processor VARCHAR(150) NOT NULL,			-- name of processor
	ScreenSize DECIMAL(4,2),					-- screen size in inches
	ScreenType VARCHAR(50) NOT NULL,			-- LCD, OLED, etc,
	RefreshRate INT,							-- display refresh rate
	BatteryCapacity INT,						-- battery capacity
	RearCameraMP DECIMAL(6,2),					-- rear camera resolution
	FrontCameraMP DECIMAL(6,2),					-- front camera resolution
	Supports5G BIT NOT NULL DEFAULT 0,			-- indicates whether 5G is supported or not
	DualSIM BIT NOT NULL DEFAULT 0,				-- indicates whether dual sim is supported or not
	ExpandableStorage BIT NOT NULL DEFAULT 0,	-- 1 = supported, 0 = not
	WaterResistance VARCHAR(30),					-- not really necessary eg. IP67, IP68
	PRIMARY KEY(SpecificationID),
	FOREIGN KEY(PhoneModelID) REFERENCES PhoneModel(PhoneModelID),

	-- Validation
	CHECK(ScreenSize IS NULL OR ScreenSize > 0),
	CHECK(RefreshRate IS NULL OR RefreshRate > 0),
	CHECK(BatteryCapacity IS NULL OR BatteryCapacity > 0),
	CHECK(RearCameraMP IS NULL OR RearCameraMP > 0),
	CHECK(FrontCameraMP IS NULL OR FrontCameraMP > 0)
);


CREATE TABLE Cart (
	CartID INT IDENTITY(1,1) NOT NULL,				-- cart identifier
	UserID INT NOT NULL,							-- links cart to the customer
	DateCreated DATETIME NOT NULL DEFAULT GETDATE(),-- date and time cart was created
	IsActive BIT NOT NULL DEFAULT 1,				-- indicates the current cart
	PRIMARY KEY(CartID),
	FOREIGN KEY(UserID) REFERENCES UserAccount(UserID)
);

CREATE TABLE CartItem (
	CartItemID INT IDENTITY(1,1) NOT NULL,			-- cart item identifier
	CartID INT NOT NULL,							-- links cart item to a shopping cart
	VariantID INT NOT NULL,							-- the phone variant to be placed in the cart
	Quantity INT NOT NULL DEFAULT 1,				-- number of units
	DateAdded DATETIME NOT NULL DEFAULT GETDATE(),	-- date item was added to the cart
	UNIQUE(CartID, VariantID),
	PRIMARY KEY(CartItemID),
	FOREIGN KEY(CartID) REFERENCES Cart(CartID),
	FOREIGN KEY(VariantID) REFERENCES PhoneVariant(VariantID),

	-- Validation
	CHECK(Quantity > 0)
);

CREATE TABLE CustomerOrder (
	OrderID INT IDENTITY(1,1) NOT NULL,					-- order identifier
	UserID INT NOT NULL,								-- links order to customer
	OrderDate DATETIME NOT NULL DEFAULT GETDATE(),		-- date and time order was made
	TotalAmount DECIMAL(12,2) NOT NULL,					-- order total
	OrderStatus VARCHAR(20) NOT NULL DEFAULT 'Received',-- order status
	PRIMARY KEY(OrderID),
	FOREIGN KEY(UserID) REFERENCES UserAccount(UserID),

	-- Validation
	CHECK(TotalAmount >= 0),
	CHECK(OrderStatus IN('Received', 'Processing', 'Completed', 'Cancelled'))
);

CREATE TABLE OrderItem (
	OrderItemID INT IDENTITY(1,1) NOT NULL,	-- order item identifier
	OrderID INT NOT NULL,					-- links the item to an order
	VariantID INT NOT NULL,					-- phone variant ordered
	Quantity INT NOT NULL,					-- number of units bought
	UnitPrice DECIMAL(12,2) NOT NULL,		-- price of phone at time of purchase
	UNIQUE(OrderID, VariantID),
	PRIMARY KEY(OrderItemID),
	FOREIGN KEY(OrderID) REFERENCES CustomerOrder(OrderID),
	FOREIGN KEY(VariantID) REFERENCES PhoneVariant(VariantID),

	-- Validation
	CHECK(Quantity > 0),
	CHECK(UnitPrice >= 0)
);

CREATE TABLE StockMovement (
	StockMovementID INT IDENTITY(1,1) NOT NULL,			-- stockmovement identifier
	VariantID INT NOT NULL,								-- variant whose stock changed
	ChangedByUserID INT NOT NULL,						-- user whose action caused the change
	MovementType VARCHAR(20) NOT NULL,					-- Sale, stockin, coreection or return
	QuantityChange INT NOT NULL,						-- + or - stock change
	MovementDate DATETIME NOT NULL DEFAULT GETDATE(),	-- date and time of change
	Notes VARCHAR(255),									-- optional explanation
	PRIMARY KEY(StockMovementID),
	FOREIGN KEY(VariantID) REFERENCES PhoneVariant(VariantID),
	FOREIGN KEY(ChangedByUserID) REFERENCES UserAccount(UserID),

	-- Validation
	CHECK(MovementType IN('StockIn', 'Sale', 'Correction', 'Return')),
	CHECK(QuantityChange <> 0)
);

CREATE TABLE UseCategory (
	UseCategoryID INT IDENTITY(1,1) NOT NULL,	-- use category identifier
	CategoryName VARCHAR(50) UNIQUE NOT NULL,	-- gaming, photography, studying, etc.
	[Description] VARCHAR(MAX) NOT NULL,		-- explains the purpose
	PRIMARY KEY(UseCategoryID)
);

CREATE TABLE PhoneSuitability (
	SuitabilityID INT IDENTITY(1,1) NOT NULL,	-- suitability identifier
	PhoneModelID INT NOT NULL,					-- phone being evaluated
	UseCategoryID INT NOT NULL,					-- intended use category
	SuitabilityScore INT NOT NULL,				-- suitability score from 1 - 10
	Explanation VARCHAR(MAX) NOT NULL,			-- Why the phone suits that purpose
	UNIQUE(PhoneModelID, UseCategoryID),
	PRIMARY KEY(SuitabilityID),
	FOREIGN KEY(PhoneModelID) REFERENCES PhoneModel(PhoneModelID),
	FOREIGN KEY(UseCategoryID) REFERENCES UseCategory(UseCategoryID),

	-- Validation
	CHECK(SuitabilityScore BETWEEN 1 AND 10)
);

CREATE TABLE RecommendationAttempt (
	AttemptID INT IDENTITY(1,1) NOT NULL,				-- recommendation attempt identifier 
	UserID INT NOT NULL,								-- customer completing the questionnaire
	MaximumBudget DECIMAL(12,2) NOT NULL,				-- customers max budget
	PreferredOS VARCHAR(30),							-- optional OS preference
	MinimumStorageGB INT NOT NULL DEFAULT 0,			-- min storage required
	BatteryPriority INT NOT NULL DEFAULT 0,				-- priority from 0 - 5
	CameraPriority INT NOT NULL DEFAULT 0,				-- priority from 0 - 5
	GamingPriority INT NOT NULL DEFAULT 0,				-- priority from 0 - 5
	BusinessPriority INT NOT NULL DEFAULT 0,			-- priority from 0 - 5
	EverydayUsePriority INT NOT NULL DEFAULT 0,			-- priority from 0 - 5
	AttemptDate DATETIME NOT NULL DEFAULT GETDATE(),	-- date and time completed
	PRIMARY KEY(AttemptID),
	FOREIGN KEY(UserID) REFERENCES UserAccount(UserID),

	-- Validation
	CHECK(MaximumBudget >= 0),
	CHECK(MinimumStorageGB >= 0),
	CHECK(BatteryPriority BETWEEN 0 AND 5),
	CHECK(CameraPriority BETWEEN 0 AND 5),
	CHECK(GamingPriority BETWEEN 0 AND 5),
	CHECK(BusinessPriority BETWEEN 0 AND 5),
	CHECK(EverydayUsePriority BETWEEN 0 AND 5)

	-- 0 = Not important
	-- 1 = Very low priority
	-- 2 = Low priority
	-- 3 = Moderate priority
	-- 4 = High priority
	-- 5 = Essential
);

CREATE TABLE RecommendationResult (
	ResultID INT IDENTITY(1,1) NOT NULL,	-- recommendation result identifier
	AttemptID INT NOT NULL,					-- questionnaire attempt
	PhoneModelID INT NOT NULL,				-- Recommended phone model
	FitScore DECIMAL(5,2) NOT NULL,			-- calculated score from 0 - 100
	RankPosition INT NOT NULL,				-- position within reults
	Explanation VARCHAR(MAX) NOT NULL,		-- why the phone fits the customer
	UNIQUE(AttemptID, PhoneModelID),
	UNIQUE(AttemptID, RankPosition),
	PRIMARY KEY(ResultID),
	FOREIGN KEY(AttemptID) REFERENCES RecommendationAttempt(AttemptID),
	FOREIGN KEY(PhoneModelID) REFERENCES PhoneModel(PhoneModelID),

	--Validation
	CHECK(FitScore BETWEEN 0 AND 100),
	CHECK(RankPosition > 0)
);

USE PhoneFitDB;
GO

SELECT *
FROM [Role];

SELECT
    UserID,
    RoleID,
    UserEmail,
    UserFirstName,
    UserSurname,
    UserIsActive
FROM UserAccount;

USE PhoneFitDB;
GO

USE PhoneFitDB;
GO

UPDATE UserAccount
SET UserIsActive = 0
WHERE UserID = 2003;
GO

USE PhoneFitDB;
GO

UPDATE PhoneModel
SET ImagePath = 'https://cdn.beebom.com/mobile/tecno-camon-50-pro-front-back-3.png'
WHERE ModelName = 'Tecno Camon 50 Pro';
GO

SELECT *
FROM CartItem
ORDER BY CartItemID DESC;

USE PhoneFitDB;
GO


SELECT
    CartID,
    UserID,
    DateCreated,
    IsActive
FROM Cart
ORDER BY UserID, CartID;

SELECT
    c.UserID,
    c.CartID,
    c.IsActive,
    ci.CartItemID,
    ci.VariantID,
    ci.Quantity,
    pm.ModelName
FROM Cart c
LEFT JOIN CartItem ci
    ON c.CartID = ci.CartID
LEFT JOIN PhoneVariant pv
    ON ci.VariantID = pv.VariantID
LEFT JOIN PhoneModel pm
    ON pv.PhoneModelID = pm.PhoneModelID
ORDER BY c.UserID, c.CartID, ci.CartItemID;

USE PhoneFitDB;
GO

SELECT *
FROM Cart;
GO

SELECT *
FROM CartItem;
GO

USE PhoneFitDB;
GO

ALTER TABLE CustomerOrder
ADD
    Subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    DiscountAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    ShippingAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    VATAmount DECIMAL(12,2) NOT NULL DEFAULT 0;
GO

SELECT *
FROM Brand
ORDER BY BrandName;

SELECT
    PhoneModelID,
    ModelName,
    [Description]
FROM PhoneModel
WHERE PhoneModelID = 3002;
USE PhoneFitDB;
GO
SELECT TOP 1 *
FROM CustomerOrder;

USE PhoneFitDB;
GO

SELECT
    c.CartID,
    c.UserID,
    c.IsActive,
    ci.CartItemID,
    ci.VariantID,
    ci.Quantity
FROM Cart c
INNER JOIN CartItem ci
    ON c.CartID = ci.CartID
WHERE c.IsActive = 1;

USE PhoneFitDB;
GO

SELECT
    CartID,
    UserID,
    IsActive
FROM Cart
WHERE CartID = 2;

SELECT TOP 10
    StockMovementID,
    VariantID,
    ChangedByUserID,
    MovementType,
    QuantityChange,
    MovementDate,
    Notes
FROM StockMovement
ORDER BY StockMovementID DESC;

SELECT
    VariantID,
    StockQuantity
FROM PhoneVariant
WHERE VariantID IN (1, 2, 1002);

SELECT *
FROM OrderItem
WHERE OrderID = 1;

SELECT *
FROM CustomerOrder
WHERE OrderID = 1;

SELECT
    VariantID,
    PhoneModelID,
    RAMGB,
    StorageGB,
    Colour,
    Price,
    StockQuantity
FROM PhoneVariant
WHERE VariantID IN (1002, 1, 2);

USE PhoneFitDB;
GO
SELECT
    CAST(UserAccountCreated AS DATE) AS RegistrationDate,
    COUNT(*) AS UsersRegistered
FROM UserAccount
GROUP BY
    CAST(UserAccountCreated AS DATE)
ORDER BY
    RegistrationDate ASC;

SELECT
    pm.PhoneModelID,
    b.BrandName,
    pm.ModelName,
    SUM(oi.Quantity) AS UnitsSold
FROM OrderItem oi
INNER JOIN PhoneVariant pv
    ON oi.VariantID = pv.VariantID
INNER JOIN PhoneModel pm
    ON pv.PhoneModelID = pm.PhoneModelID
INNER JOIN Brand b
    ON pm.BrandID = b.BrandID
GROUP BY
    pm.PhoneModelID,
    b.BrandName,
    pm.ModelName
ORDER BY
    UnitsSold DESC;

SELECT COUNT(DISTINCT pv.PhoneModelID) AS DifferentProductsSold
FROM OrderItem oi
INNER JOIN PhoneVariant pv
    ON oi.VariantID = pv.VariantID;

-- Total Orders
SELECT COUNT(*) AS TotalOrders
FROM CustomerOrder;


-- Total Revenue
SELECT SUM(TotalAmount) AS TotalRevenue
FROM CustomerOrder;


-- Total Units Sold
SELECT SUM(Quantity) AS TotalUnitsSold
FROM OrderItem;


-- Products Currently On Hand
SELECT SUM(StockQuantity) AS ProductsOnHand
FROM PhoneVariant;


-- Low Stock Variants
SELECT COUNT(*) AS LowStockVariants
FROM PhoneVariant
WHERE StockQuantity <= LowStockLevel;

SELECT
    pm.PhoneModelID,
    b.BrandName,
    pm.ModelName
FROM PhoneModel pm
INNER JOIN Brand b
    ON pm.BrandID = b.BrandID
ORDER BY b.BrandName, pm.ModelName;

-- HONOR
UPDATE PhoneModel
SET ModelName = 'Magic6 Ultimate'
WHERE PhoneModelID = 1022;

UPDATE PhoneModel
SET ModelName = 'Magic8 Pro Air'
WHERE PhoneModelID = 1015;

UPDATE PhoneModel
SET ModelName = 'X6c'
WHERE PhoneModelID = 4;

UPDATE PhoneModel
SET ModelName = 'X70 Pro Max'
WHERE PhoneModelID = 1016;


-- Huawei
UPDATE PhoneModel
SET ModelName = 'Enjoy 90'
WHERE PhoneModelID = 1005;

UPDATE PhoneModel
SET ModelName = 'Mate 80 Pro'
WHERE PhoneModelID = 1013;

UPDATE PhoneModel
SET ModelName = 'Mate 80 Pro Max'
WHERE PhoneModelID = 1012;

UPDATE PhoneModel
SET ModelName = 'nova Y72'
WHERE PhoneModelID = 1006;


-- OnePlus
UPDATE PhoneModel
SET ModelName = 'Ace 3V'
WHERE PhoneModelID = 1027;

UPDATE PhoneModel
SET ModelName = 'Ace 7'
WHERE PhoneModelID = 1026;

UPDATE PhoneModel
SET ModelName = 'Nord CE 2 Lite 5G'
WHERE PhoneModelID = 1028;


-- OPPO
UPDATE PhoneModel
SET ModelName = 'A1 5G'
WHERE PhoneModelID = 1031;

UPDATE PhoneModel
SET ModelName = 'A6 4G'
WHERE PhoneModelID = 5;

UPDATE PhoneModel
SET ModelName = 'Reno15 Pro Max'
WHERE PhoneModelID = 1030;


-- Realme
UPDATE PhoneModel
SET ModelName = 'Narzo 80 Lite 5G'
WHERE PhoneModelID = 1033;

UPDATE PhoneModel
SET ModelName = 'Note 80'
WHERE PhoneModelID = 1032;


-- Samsung
UPDATE PhoneModel
SET ModelName = 'Galaxy A04e'
WHERE PhoneModelID = 1003;

UPDATE PhoneModel
SET ModelName = 'Galaxy A27'
WHERE PhoneModelID = 1002;

UPDATE PhoneModel
SET ModelName = 'Galaxy S26 Ultra'
WHERE PhoneModelID = 1036;

UPDATE PhoneModel
SET ModelName = 'Galaxy Z TriFold'
WHERE PhoneModelID = 1004;


-- Sony
UPDATE PhoneModel
SET ModelName = 'Xperia 1 VIII'
WHERE PhoneModelID = 1029;


-- Tecno
UPDATE PhoneModel
SET ModelName = 'Camon 50 Pro'
WHERE PhoneModelID = 1034;

UPDATE PhoneModel
SET ModelName = 'Spark 50'
WHERE PhoneModelID = 1035;


-- Xiaomi
UPDATE PhoneModel
SET ModelName = '17T Pro'
WHERE PhoneModelID = 1025;

UPDATE PhoneModel
SET ModelName = 'Poco C85x'
WHERE PhoneModelID = 1023;

UPDATE PhoneModel
SET ModelName = 'Redmi Turbo 5 Max'
WHERE PhoneModelID = 1024;
SELECT
    pm.PhoneModelID,
    b.BrandName,
    pm.ModelName
FROM PhoneModel pm
INNER JOIN Brand b
    ON pm.BrandID = b.BrandID
ORDER BY b.BrandName, pm.ModelName;