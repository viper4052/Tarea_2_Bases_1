USE [tarea2BD]
GO


CREATE TABLE dbo.Empleado
(
	Id Int IDENTITY(1,1) PRIMARY KEY
	, IdPuesto INT NOT NULL FOREIGN KEY REFERENCES dbo.Puesto(Id)
	, Nombre VARCHAR (128) NOT NULL
	, ValorDocumentoIdentidad INT NOT NULL
	, FechaContratacion DATE NOT NULL
	, SaldoVacaciones MONEY NOT NULL DEFAULT 0.00 
	, EsActivo INT NOT NULL DEFAULT 1       --si dice 1 es activo, 0 es no activo 
);