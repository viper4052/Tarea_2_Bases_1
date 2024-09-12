USE [tarea2BD]
GO
BEGIN 
									-- PRIMERO INGRESEMOS LAS TABLAS DE CATALOGO 

-- Hacemos la tabla variable, funcionara para extraer todos los datos
DECLARE  @XmlTable TABLE
(
	XmlCol XML
);

--Metemos el  XML a la tabla variable 
INSERT INTO @XmlTable(XmlCol)
SELECT BulkColumn
FROM OPENROWSET
(
    BULK 'C:\prueba\datos.xml'
	, SINGLE_BLOB
)
AS x;


                         --AHORA CARGUEMOS LOS DATOS DE PUESTO
INSERT INTO dbo.Puesto  
SELECT result.Nombre, result.SalarioxHora
FROM @XmlTable
CROSS APPLY 
(
    SELECT
        Nombre = z.value('@Nombre', 'VARCHAR(128)')
		, SalarioxHora = z.value('@SalarioxHora', 'MONEY')
    FROM XmlCol.nodes('Datos/Puestos/Puesto') AS T(z)
) AS result;


                         --AHORA CARGUEMOS LOS DATOS DE Tipo de Movimiento
INSERT INTO dbo.TipoMovimiento 
Select result.Id
      , result.Nombre
	  , result.TipoDeAccion
FROM @XmlTable
CROSS APPLY 
(
    SELECT
		Id = z.value('@Id', 'INT')
		, Nombre = z.value('@Nombre', 'VARCHAR(128)')
		, TipoDeAccion = z.value('@TipoAccion', 'VARCHAR(128)')
    FROM XmlCol.nodes('Datos/TiposMovimientos/TipoMovimiento') T(z)
) result;

                         --AHORA CARGUEMOS LOS DATOS DE Error
INSERT INTO dbo.Error 
Select result.Codigo
	   , result.Descripcion
FROM @XmlTable
CROSS APPLY 
(
    SELECT
		Codigo = z.value('@Codigo', 'INT')
		, Descripcion = z.value('@Descripcion', 'VARCHAR(128)')
    FROM XmlCol.nodes('Datos/Errores/error') T(z)
) result;


                         --AHORA CARGUEMOS LOS DATOS DE Tipo de Eveno
INSERT INTO dbo.TipoEvento 
Select result.Id
       , result.Nombre
FROM @XmlTable
CROSS APPLY 
(
    SELECT
		Id = z.value('@Id', 'INT')
		, Nombre = z.value('@Nombre', 'VARCHAR(128)')
    FROM XmlCol.nodes('Datos/TiposEvento/TipoEvento') T(z)
) result;



                           --AHORA TOCA CARGAR EL RESTO DE DATOS 


      --AHORA CARGUEMOS LOS DATOS DE USUARIo
INSERT INTO [dbo].[Usuario] 
Select result.Id
	   , result.Username
	   , result.Pass 
FROM @XmlTable
CROSS APPLY 
(
    SELECT
		Id = z.value('@Id', 'INT')
		, Username = z.value('@Username','VARCHAR(128)')
		, Pass = z.value('@Pass','VARCHAR(128)')
    FROM XmlCol.nodes('Datos/Usuarios/usuario') T(z)
) result;

      --AHORA CARGUEMOS LOS Empleados 


DECLARE  @empleado TABLE -- a este si es mejor hacerle una tabla variable para 
(                        -- luego hacer el InnerJoin con Puesto
	Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
	, Puesto VARCHAR(128) NOT NULL 
	, Nombre VARCHAR(128) NOT NULL
	, ValorDocumentoIdentidad INT NOT NULL
	, FechaContratacion DATE NOT NULL
	, SaldoVacaciones MONEY NOT NULL DEFAULT 0.0
	, EsActivo INT NOT NULL DEFAULT 1
);

INSERT INTO @empleado
(	
	Puesto
	, Nombre
	, ValorDocumentoIdentidad
	, FechaContratacion
)
Select result.Puesto
       , result.Nombre
	   , result.ValorDocumentoIdentidad
	   , result.FechaContratacion 
FROM @XmlTable
CROSS APPLY 
(
    SELECT
		Puesto = z.value('@Puesto','VARCHAR(128)')
		, Nombre = z.value('@Nombre', 'VARCHAR(128)')
		, ValorDocumentoIdentidad = z.value('@ValorDocumentoIdentidad','INT')
		, FechaContratacion = z.value('@FechaContratacion','DATE')
    FROM XmlCol.nodes('Datos/Empleados/empleado') T(z)
) result;

--AHORA HACER INNER JOIN ENTRE @empleado, dbo.Puesto para dbo.Empleado
INSERT dbo.Empleado
(
	IdPuesto
	, Nombre
	, ValorDocumentoIdentidad
	, FechaContratacion
	, SaldoVacaciones
	, EsActivo
)
SELECT P.Id
	   , E.Nombre 
	   , E.ValorDocumentoIdentidad 
	   , E.FechaContratacion 
	   , E.SaldoVacaciones 
	   , E.EsActivo 
FROM @empleado E
INNER JOIN dbo.Puesto P ON E.Puesto = P.Nombre;



--AHORA CARGUEMOS LOS Movimientos  


DECLARE  @movimientos TABLE -- a este si es mejor hacerle una tabla variable para 
(                           -- luego hacer el InnerJoin con todos los 3 Fks
	ValorDocId INT NOT NULL 
	, IdTipoMovimiento VARCHAR(128) NOT NULL
	, Monto INT NOT NULL
	, PostByUser VARCHAR(128) NOT NULL
	, PostInIP VARCHAR(128) NOT NULL
	, PostTime DATETIME NOT NULL
);

INSERT INTO @movimientos
(
	ValorDocId
	, IdTipoMovimiento 
	, Monto 
	, PostByUser
	, PostInIP 
	, PostTime 
)
Select result.ValorDocId
	   , result.IdTipoMovimiento 
	   , result.Monto 
	   , result.PostByUser
	   , result.PostInIP 
	   , result.PostTime  
FROM @XmlTable
CROSS APPLY 
(
    SELECT
		ValorDocId = z.value('@ValorDocId','INT')
		, IdTipoMovimiento = z.value('@IdTipoMovimiento', 'VARCHAR(128)')
		, Monto = z.value('@Monto','MONEY')
		, PostByUser = z.value('@PostByUser', 'VARCHAR(128)') 
		, PostInIP = z.value('@PostInIP','VARCHAR(128)')
		, PostTime = z.value('@PostTime','DATETIME')
    FROM XmlCol.nodes('Datos/Movimientos/movimiento') T(z)
) result;

--AHORA HACER INNER JOIN ENTRE @movimiento, dbo.empleado 
INSERT dbo.Movimiento
(
	IdEmpleado
	, Monto
	, NuevoSaldo
	, IdPostByUser
	, PostInIP
	, PostTime
	, IdTipoMovimiento
)
SELECT E.Id -- id del empleado 
	   , M.Monto
	   , E.SaldoVacaciones + M.Monto AS NuevoSaldo -- sumar/restar Monto mas saldoVacaciones
	   , U.Id --Id del usuario 
	   , M.PostInIP
	   , M.PostTime
	   , V.Id --Id del tipo de Mov 
FROM @movimientos M
INNER JOIN dbo.Empleado E ON M.ValorDocId = E.ValorDocumentoIdentidad
INNER JOIN dbo.Usuario U ON M.PostByUser = U.Username
INNER JOIN dbo.TipoMovimiento V ON M.IdTipoMovimiento = V.Nombre;

END
GO