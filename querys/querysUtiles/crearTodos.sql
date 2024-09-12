USE [tarea2BD]
GO

CREATE TABLE [dbo].[Puesto]
(
	Id Int IDENTITY(1,1) PRIMARY KEY
	, Nombre VARCHAR (128) NOT NULL
	, SalarioxHora MONEY NOT NULL
)
GO

CREATE TABLE [dbo].[Empleado]
(
	Id Int IDENTITY(1,1) PRIMARY KEY
	, IdPuesto INT NOT NULL FOREIGN KEY REFERENCES dbo.Puesto(Id)
	, Nombre VARCHAR (128) NOT NULL
	, ValorDocumentoIdentidad INT NOT NULL
	, FechaContratacion DATE NOT NULL
	, SaldoVacaciones MONEY NOT NULL DEFAULT 0.00 
	, EsActivo INT NOT NULL DEFAULT 1       --si dice 1 es activo, 0 es no activo 
);
GO

CREATE TABLE dbo.TipoMovimiento
(
	Id INT PRIMARY KEY
	, Nombre VARCHAR (128) NOT NULL
	, TipoDeAccion VARCHAR (128) NOT NULL
);
GO

CREATE TABLE [dbo].[Usuario]
(
	Id Int PRIMARY KEY
	, Username VARCHAR (128) NOT NULL
	, Pass VARCHAR(128) NOT NULL
)
GO 

CREATE TABLE dbo.Movimiento
(
	Id INT IDENTITY (1,1) PRIMARY KEY
	, IdEmpleado INT NOT NULL FOREIGN KEY REFERENCES dbo.Empleado(Id)
	, IdTipoMovimiento INT NOT NULL FOREIGN KEY REFERENCES dbo.TipoMovimiento(Id)
	, Monto MONEY NOT NULL
	, NuevoSaldo MONEY NOT NULL
	, IdPostByUser INT NOT NULL FOREIGN KEY REFERENCES dbo.Usuario(Id)
	, PostInIP VARCHAR(128) NOT NULL 
	, PostTime DATETIME NOT NULL 
);

GO

CREATE TABLE [dbo].[TipoEvento]
(
	Id Int PRIMARY KEY
	, Nombre VARCHAR (128) NOT NULL
)
GO

CREATE TABLE [dbo].[BitacoraEvento]
(
	Id Int IDENTITY(1,1) PRIMARY KEY
	, IdTipoEvento INT NOT NULL FOREIGN KEY REFERENCES dbo.TipoEvento(id)
	, Descripcion VARCHAR (128) NOT NULL
	, IdPostByUser INT NOT NULL FOREIGN KEY REFERENCES dbo.Usuario(id)
	, PostInIP VARCHAR (128) NOT NULL
	, PostTime DATETIME NOT NULL
)
GO

CREATE TABLE [dbo].[DBError](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](100) NULL,
	[Number] [int] NULL,
	[State] [int] NULL,
	[Severity] [int] NULL,
	[Line] [int] NULL,
	[Procedure] [varchar](max) NULL,
	[Message] [varchar](max) NULL,
	[DateTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[Error]
(
	Id INT IDENTITY(1,1) PRIMARY KEY
	, Codigo INT NOT NULL
	, Descripcion VARCHAR (128) NOT NULL
)
GO