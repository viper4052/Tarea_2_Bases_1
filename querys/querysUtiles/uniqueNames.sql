--Unique values 

ALTER TABLE dbo.Empleado
ADD CONSTRAINT Nombre_Unico UNIQUE (Nombre);

ALTER TABLE dbo.Empleado
ADD CONSTRAINT ValorId_Unico UNIQUE (ValorDocumentoIdentidad);