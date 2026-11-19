CREATE TABLE PhoneImage (					-- Different views of the phone - can implement later if needed
	ImageID INT IDENTITY(1,1) NOT NULL,		-- image view identifier
	PhoneModelID INT NOT NULL,				-- links the image view to a phone model
	ImagePath VARCHAR(MAX) NOT NULL,		-- the path to the image view
	AltText VARCHAR(150) NOT NULL,			-- image description
	DisplayOrder INT NOT NULL DEFAULT 1,	-- order to display the images
	IsPrimary BIT NOT NULL DEFAULT 0,		-- 1 = primary image, 0 = additional image
	UNIQUE(PhoneModelID, ImagePath),		-- prevents the same image from being added twice to one phone
	UNIQUE(PhoneModelID, DisplayOrder),		-- prevents 2 images for the same phone both being assigned display position 1
	PRIMARY KEY(ImageID),
	FOREIGN KEY(PhoneModelID) REFERENCES PhoneModel(PhoneModelID),

	-- Validation
	CHECK(DisplayOrder > 0)
);

CREATE TABLE OrderStatusHistory (
	StatusHistoryID INT IDENTITY(1,1) NOT NULL,			-- status history identifier
	OrderID INT NOT NULL,								-- order being updated
	[Status] VARCHAR(20) NOT NULL,						-- new order status
	UpdatedByUserID INT NOT NULL,						-- manager updating the status
	UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),	-- date and time of update
	Notes VARCHAR(MAX),									-- optional notes explanation
	PRIMARY KEY(StatusHistoryID),
	FOREIGN KEY(OrderID) REFERENCES CustomerOrder(OrderID),
	FOREIGN KEY(UpdatedByUserID) REFERENCES UserAccount(UserID),

	-- Validation
	CHECK([Status] IN('Received', 'Processing', 'Completed', 'Cancelled'))
);

CREATE TABLE Review (
	ReviewID INT IDENTITY(1,1) NOT NULL,				-- review identifier
	UserID INT NOT NULL,								-- customer submitting the review
	PhoneModelID INT NOT NULL,							-- phone being reviewed
	Rating INT NOT NULL,								-- rating from 1 - 5
	Comment VARCHAR(MAX) NOT NULL,						-- customer review
	ReviewDate DATETIME NOT NULL DEFAULT GETDATE(),		-- date and time submitted
	IsApproved BIT NOT NULL DEFAULT 0,					-- manager approval status
	UNIQUE(UserID, PhoneModelID),						-- one review per customer per phone model
	PRIMARY KEY(ReviewID),
	FOREIGN KEY(UserID) REFERENCES UserAccount(UserID),
	FOREIGN KEY(PhoneModelID) REFERENCES PhoneModel(PhoneModelID),

	-- Validation
	CHECK(Rating BETWEEN 1 AND 5)
);

CREATE TABLE ProductRequest (
	ProductRequestID INT IDENTITY(1,1) NOT NULL,			-- product request identifier
	UserID INT NOT NULL,									-- customer making the request
	RequestedBrand VARCHAR(100) NOT NULL,					-- requested phone brand
	RequestedModel VARCHAR(150) NOT NULL,					-- requested phone model
	RequestDate DATETIME NOT NULL DEFAULT GETDATE(),		-- date and time submitted	
	RequestStatus VARCHAR(20) NOT NULL DEFAULT 'Submitted',	-- Submitted, Reviewed or Added
	ManagerResponse VARCHAR(MAX),							-- Optional response
	PRIMARY KEY(ProductRequestID),
	FOREIGN KEY(UserID) REFERENCES UserAccount(UserID),

	-- Validation
	CHECK(RequestStatus IN('Submitted', 'Reviewed', 'Added', 'Declined'))
);

CREATE TABLE Feedback (
	FeedbackID INT IDENTITY(1,1) NOT NULL,				-- feedback identifier
	UserID INT NOT NULL,								-- user submitting feedback
	FeedbackType VARCHAR(20) NOT NULL,					-- suggestion, issue or complaint
	[Subject] VARCHAR(150) NOT NULL,					-- feedback subject
	[Message] VARCHAR(MAX) NOT NULL,					-- feedback message
	DateSubmitted DATETIME NOT NULL DEFAULT GETDATE(),	-- date and time submitted
	[Status] VARCHAR(20) NOT NULL DEFAULT 'Open',		-- current feedback status
	PRIMARY KEY(FeedbackID),
	FOREIGN KEY(UserID) REFERENCES UserAccount(UserID),

	-- Validation
	CHECK(FeedbackType IN('Suggestion', 'Issue', 'Complaint')),
	CHECK([Status] IN('Open', 'In Progress', 'Resolved', 'Closed'))
);