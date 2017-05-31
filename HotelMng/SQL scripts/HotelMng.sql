﻿CREATE DATABASE HotelManagement
GO
USE HotelManagement
GO

CREATE TABLE ACCOUNT
(
	UserName	VARCHAR(20) NOT NULL PRIMARY KEY,
	Password	VARCHAR(20) NOT NULL,
)

GO
CREATE TABLE TABLE_NATIONALITY
(
	NatId	INT IDENTITY PRIMARY KEY,
	NatName NVARCHAR(20)
)
GO
CREATE TABLE ROOM_TYPE												--Loại phòng
(
	RoomTypeId		CHAR(1) NOT NULL PRIMARY KEY,		--QD1--
	PriceByDay		MONEY NOT NULL,
	PriceFirstHour	MONEY NOT NULL,
	PricePerHour	MONEY NOT NULL,
	Note			NVARCHAR(100)
)
--EXEC sp_rename 'ROOM_TYPE.[[Price1stHour]]]', 'PriceFirstHour', 'COLUMN'
GO
CREATE TABLE ROOM_STATUS
(
	StatusID	INT IDENTITY NOT NULL PRIMARY KEY,
	StatusName	NVARCHAR(20)
)													
GO
CREATE TABLE ROOM													--Phòng
(
	RoomId		INT NOT NULL PRIMARY KEY,
	RoomTypeId	CHAR(1),
	Description	NVARCHAR(200),
	StatusId	INT,
	Capacity	SMALLINT
	FOREIGN KEY (RoomTypeId) REFERENCES ROOM_TYPE(RoomTypeId),
	FOREIGN KEY (StatusId) REFERENCES ROOM_STATUS(StatusId)
)
GO
CREATE TABLE RENTER														--Người Thuê
(
	RenterId	VARCHAR(20) NOT NULL PRIMARY KEY,
	Name		NVARCHAR(30) NOT NULL,
	Gender		bit NOT NULL,
	PhoneNum	VARCHAR(15),
	NatId		INT,													--QD2--
	IDENTITYNum	VARCHAR(20),
	Address		VARCHAR(40)

	FOREIGN KEY (NatId) REFERENCES TABLE_NATIONALITY(NatId)
)
GO
CREATE TABLE SERVICE_TYPE
(
	SvTypeId	INT IDENTITY(0,1) PRIMARY KEY,
	SvTypeName	NVARCHAR(30),
)
GO
CREATE TABLE SERVICE 
(
	ServId	INT IDENTITY PRIMARY KEY,
	Name	VARCHAR(15),
	Price	MONEY NOT NULL DEFAULT 0,
	Unit	NVARCHAR(10),
	SvTypeId INT,
)

GO
CREATE TABLE BILL														--hóa đơn
(
	BillId		VARCHAR(20) NOT NULL PRIMARY KEY,
	RenterId	VARCHAR(20),
	RoomId		INT,
	TotalMoney	MONEY NOT NULL,
	
	FOREIGN KEY (RoomId) REFERENCES ROOM(RoomId),
	FOREIGN KEY (RenterId) REFERENCES RENTER(RenterId),)
GO
CREATE TABLE REG_FORM														--phiếu thuê phòng
(
	FormId		INT IDENTITY PRIMARY KEY,
	CheckIn		SMALLDATETIME NOT NULL,
	CheckOut	SMALLDATETIME,
	RenterId	VARCHAR(20),
	RoomId		INT,
	BillId		VARCHAR(20),
	Rental		MONEY,

	FOREIGN KEY (RenterId) REFERENCES RENTER(RenterId),
	FOREIGN KEY (RoomId) REFERENCES ROOM(RoomId),
	FOREIGN KEY (BillId) REFERENCES BILL(BillId),
)
GO
CREATE TABLE USE_SERVICES
(
	ServId	INT,
	FormId	INT,
	Time	DateTime,

	PRIMARY KEY (ServId, FormId),
	FOREIGN KEY (ServId) REFERENCES SERVICE(ServId),
	FOREIGN KEY (FormId) REFERENCES REG_FORM(FormId)
)
GO
CREATE TABLE ROOMMATE
(
	Name	NVARCHAR(30),
	IdentityNum VARCHAR(10),
	NatId	INT,
	FormId	INT,
	RenterId VARCHAR(20),

	PRIMARY KEY (FormId,RenterId),
	FOREIGN KEY (FormId) REFERENCES REG_FORM(FormId),
	FOREIGN KEY (RenterId) REFERENCES RENTER(RenterId),
	FOREIGN KEY (NatId) REFERENCES TABLE_NATIONALITY(NatId)
)
GO
CREATE TABLE FEE
(
	Id	INT IDENTITY PRIMARY KEY,
	FeeForEachMoreGuest	FLOAT NOT NULL,
	FeeForForeigner FLOAT NOT NULL
)
GO
------------------------Procedure--
CREATE PROC USP_GetAllRoommatesByRenterId
	@renterid VARCHAR(20)
AS
	SELECT RM.Name, RM.IdentityNum, NAT.NatName
	FROM dbo.ROOMMATE AS RM
	JOIN dbo.TABLE_NATIONALITY AS NAT
		ON NAT.NatId = RM.NatId
	WHERE RM.RenterId = @renterid
GO
CREATE PROC USP_GetAllServicesInfo
AS
	SELECT SV.ServId, SV.Name, SV.Price, SV.SvTypeId, SV.Unit, ST.SvTypeName
	FROM dbo.SERVICE AS SV 
	JOIN dbo.SERVICE_TYPE AS ST
		ON ST.SvTypeId = SV.SvTypeId

GO
CREATE PROC USP_GetAllRoomInfo
AS
	SELECT R.RoomId, R.RoomTypeId, R.StatusId, R.Capacity ,RS.StatusName, R.Description
	FROM dbo.ROOM AS R
	JOIN dbo.ROOM_STATUS AS RS
		ON RS.StatusID = R.StatusId
GO
CREATE PROC USP_GetRoomStatusInfo
AS
	SELECT RS.StatusId, RS.StatusName, COUNT(R.RoomId) AS ITEMCOUNT
	FROM dbo.ROOM AS R
	RIGHT JOIN dbo.ROOM_STATUS AS RS
		ON RS.StatusID = R.StatusId
	GROUP BY RS.StatusId, RS.StatusName
GO
CREATE PROC USP_GetDataForReporting
	@month SMALLINT,
	@year  INT
AS
	DECLARE @temptable TABLE
	(RoomTypeId CHAR(1),
	Income		MONEY)
	DECLARE @total MONEY

	INSERT INTO @temptable ( RoomTypeId, Income )
		SELECT	RT.RoomTypeId, SUM(RF.Rental) AS Income
		FROM	dbo.ROOM_TYPE AS RT
		JOIN	dbo.ROOM AS R
			ON	R.RoomTypeId = RT.RoomTypeId
		JOIN	dbo.REG_FORM AS RF
			ON	RF.RoomId = R.RoomId
		WHERE	MONTH(RF.CheckOut) = @month AND YEAR(RF.CheckOut) = @year
		GROUP BY RT.RoomTypeId
	
	SELECT	@total = SUM(t.Income)
	FROM	@temptable AS t
	SELECT	t.RoomTypeId AS N'Loại phòng', t.Income N'Thu nhập', t.Income / @total AS N'Tỉ lệ'
	FROM	@temptable AS t
GO
CREATE PROC USP_GetNewestServiceInfo
AS
	SELECT TOP 1 S.ServId, ST.SvTypeName
	FROM dbo.SERVICE AS S 
	JOIN dbo.SERVICE_TYPE AS ST
		ON ST.SvTypeId = S.SvTypeId
	ORDER BY S.ServId DESC
GO