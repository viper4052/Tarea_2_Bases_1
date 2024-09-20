USE [tarea2BD]
GO
CREATE TABLE [dbo].[BitacoraEvento]
(
	Id Int IDENTITY(1,1) PRIMARY KEY
	, IdTipoEvento INT NOT NULL FOREIGN KEY REFERENCES dbo.TipoEvento(id)
	, Descripcion VARCHAR (128) NOT NULL
	, IdPostByUser INT FOREIGN KEY REFERENCES dbo.Usuario(id)
	, PostInIP VARCHAR (128) NOT NULL
	, PostTime DATETIME NOT NULL
)