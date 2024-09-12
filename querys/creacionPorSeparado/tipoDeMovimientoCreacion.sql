USE [tarea2BD]
go

CREATE TABLE dbo.TipoMovimiento
(
	Id INT PRIMARY KEY
	, Nombre VARCHAR (128) NOT NULL
	, TipoDeAccion VARCHAR (128) NOT NULL
);