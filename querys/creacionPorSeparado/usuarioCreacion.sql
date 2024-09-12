USE [tarea2BD]
GO


CREATE TABLE [dbo].[Usuario]
(
	Id Int PRIMARY KEY
	, Username VARCHAR (128) NOT NULL
	, Pass VARCHAR(128) NOT NULL
)