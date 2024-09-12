USE [tarea2BD]
GO

CREATE TABLE [dbo].[Puesto]
(
	Id Int IDENTITY(1,1) PRIMARY KEY
	, Nombre VARCHAR (128) NOT NULL
	, SalarioxHora MONEY NOT NULL
)