﻿CREATE DATABASE HotelManagement
GO
USE HotelManagement
GO

CREATE TABLE ACCOUNT
(
	UserName	VARCHAR(20) not null PRIMARY KEY,
	Password	VARCHAR(20) not null,
)

GO
CREATE TABLE ROOM_TYPE												--Loại phòng
(
	RoomTypeId	CHAR(1) not null PRIMARY KEY,		--QD1--
	Price		MONEY not null,
	Note		VARCHAR(100)
)												
GO
CREATE TABLE ROOM_STATUS
(
	StatusID	INT IDENTITY not null PRIMARY KEY,
	StatusName	NVARCHAR(20)
)													
GO
CREATE TABLE ROOM													--Phòng
(
	RoomId		INT not null PRIMARY KEY,
	RoomTypeId	CHAR(1),
	Description	NVARCHAR(200),
	NumOfBed	INT,
	PeoPerBed	INT,
	MaxCapacity INT,
	Floor		INT,
	StatusId	INT 
	FOREIGN KEY (RoomTypeId) REFERENCES ROOM_TYPE(RoomTypeId),
	FOREIGN KEY (StatusId) REFERENCES ROOM_STATUS(StatusId)
)
GO
CREATE TABLE NATIONALITY
(
	NatId		INT IDENTITY NOT NULL PRIMARY KEY,
	Name		NVARCHAR(20)
)
CREATE TABLE RENTER														--Người Thuê
(
	RenterId	VARCHAR(20) not null PRIMARY KEY,
	Name		NVARCHAR(30) not null,
	Gender		bit not null,
	PhoneNum	VARCHAR(15),
	NatId		INT,													--QD2--
	IDENTITYNum	VARCHAR(20),
	Address		VARCHAR(40)

	FOREIGN KEY (NatId) REFERENCES NATIONALITY(NatId)
)
GO
CREATE TABLE SERVICE_TYPE
(
	SvTypeId	INT IDENTITY PRIMARY KEY,
	SvTypeName	NVARCHAR(30),
)
GO
CREATE TABLE SERVICE 
(
	ServId	INT IDENTITY PRIMARY KEY,
	Name	VARCHAR(15),
	Price	MONEY NOT NULL DEFAULT 0,
	SvTypeId INT,
	FOREIGN KEY (SvTypeId) REFERENCES SERVICE_TYPE(SvTypeId)
)
GO
CREATE TABLE BILL														--hóa đơn
(
	BillId		VARCHAR(20) not null PRIMARY KEY,
	RenterId	VARCHAR(20),
	RoomId		INT,
	TotalMoney	MONEY not null,
	
	FOREIGN KEY (RoomId) REFERENCES ROOM(RoomId),
	FOREIGN KEY (RenterId) REFERENCES RENTER(RenterId),)
GO
CREATE TABLE TABLE_NATIONALITY
(
	NatId	INT IDENTITY PRIMARY KEY,
	NatName NVARCHAR(20)
)
GO
CREATE TABLE REG_FORM														--phiếu thuê phòng
(
	FormId		INT IDENTITY PRIMARY KEY,
	CheckIn		smalldatetime not null,
	CheckOut	smalldatetime,
	RenterId	VARCHAR(20),
	RoomId		INT,
	BillId		VARCHAR(20),
	NatId		INT,

	FOREIGN KEY (RenterId) REFERENCES RENTER(RenterId),
	FOREIGN KEY (RoomId) REFERENCES ROOM(RoomId),
	FOREIGN KEY (BillId) REFERENCES BILL(BillId),
	FOREIGN KEY (NatId) REFERENCES TABLE_NATIONALITY(NatId)
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
CREATE TABLE APPLIANCE
(
	ApplianceId	INT IDENTITY PRIMARY KEY,
	Name		NVARCHAR(30)
)
GO
CREATE TABLE HAVE_APPLIANCE
(
	ApplianceId INT,
	RoomId		INT,
	PRIMARY KEY(ApplianceId, RoomId),
	FOREIGN KEY(ApplianceId) REFERENCES APPLIANCE(ApplianceId),
	FOREIGN KEY(RoomId) REFERENCES ROOM(RoomId)
)
GO
CREATE TABLE ROOMMATE
(
	Name	VARCHAR(30),
	NatId	INT,
	FormId	INT,
	RenterId VARCHAR(20),

	PRIMARY KEY (FormId,RenterId),
	FOREIGN KEY (FormId) REFERENCES REG_FORM(FormId),
	FOREIGN KEY (RenterId) REFERENCES RENTER(RenterId),
	FOREIGN KEY (NatId) REFERENCES TABLE_NATIONALITY(NatId)
)
GO