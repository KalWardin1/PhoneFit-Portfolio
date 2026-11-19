USE PhoneFitDB;
GO

IF OBJECT_ID('RecommendationResult', 'U') IS NOT NULL
    DROP TABLE RecommendationResult;
GO

IF OBJECT_ID('RecommendationAttempt', 'U') IS NOT NULL
    DROP TABLE RecommendationAttempt;
GO

IF OBJECT_ID('PhoneSuitability', 'U') IS NOT NULL
    DROP TABLE PhoneSuitability;
GO

IF OBJECT_ID('UseCategory', 'U') IS NOT NULL
    DROP TABLE UseCategory;
GO


/* Inventory tables */

IF OBJECT_ID('StockMovement', 'U') IS NOT NULL
    DROP TABLE StockMovement;
GO


/* Order tables */

IF OBJECT_ID('OrderItem', 'U') IS NOT NULL
    DROP TABLE OrderItem;
GO

IF OBJECT_ID('CustomerOrder', 'U') IS NOT NULL
    DROP TABLE CustomerOrder;
GO


/* Cart tables */

IF OBJECT_ID('CartItem', 'U') IS NOT NULL
    DROP TABLE CartItem;
GO

IF OBJECT_ID('Cart', 'U') IS NOT NULL
    DROP TABLE Cart;
GO


/* Product catalogue tables */

IF OBJECT_ID('PhoneSpecification', 'U') IS NOT NULL
    DROP TABLE PhoneSpecification;
GO

IF OBJECT_ID('PhoneVariant', 'U') IS NOT NULL
    DROP TABLE PhoneVariant;
GO

IF OBJECT_ID('PhoneModel', 'U') IS NOT NULL
    DROP TABLE PhoneModel;
GO

IF OBJECT_ID('Brand', 'U') IS NOT NULL
    DROP TABLE Brand;
GO


/* User-management tables */

IF OBJECT_ID('UserAccount', 'U') IS NOT NULL
    DROP TABLE UserAccount;
GO

IF OBJECT_ID('Role', 'U') IS NOT NULL
    DROP TABLE [Role];
GO