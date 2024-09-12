USE [tarea2BD]
GO


CREATE TABLE [dbo].[Error]
(
	Id Int IDENTITY(1,1) PRIMARY KEY
	, Codigo INT NOT NULL
	, Descripcion VARCHAR (128) NOT NULL
)