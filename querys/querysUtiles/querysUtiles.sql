USE [tarea2BD]
SELECT * FROM dbo.Empleado
SELECT * FROM  dbo.Movimiento
SELECT * FROM  dbo.TipoMovimiento
SELECT * FROM  dbo.Usuario
SELECT * FROM  dbo.Puesto
SELECT * FROM  dbo.TipoEvento
SELECT * FROM  dbo.Error
SELECT * FROM  dbo.DBError
SELECT * FROM  dbo.BitacoraEvento


DBCC CHECKIDENT ('Error', RESEED, 0);
DBCC CHECKIDENT ('Movimiento', RESEED, 0);
DBCC CHECKIDENT ('Empleado', RESEED, 0);
DBCC CHECKIDENT ('Puesto', RESEED, 0);
DBCC CHECKIDENT ('BitacoraEvento', RESEED, 0);

DELETE FROM  dbo.Movimiento
DELETE FROM  dbo.BitacoraEvento
DELETE FROM dbo.Empleado
DELETE FROM  dbo.Puesto
DELETE FROM  dbo.TipoMovimiento
DELETE FROM  dbo.TipoEvento
DELETE FROM  dbo.Usuario
DELETE FROM  dbo.Error
DELETE FROM  dbo.DBError

