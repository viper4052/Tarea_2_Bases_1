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
    FROM XmlCol.nodes('Datos/Error/error') T(z)
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
		, Username = z.value('@Nombre','VARCHAR(128)')
		, Pass = z.value('@Pass','VARCHAR(128)')
    FROM XmlCol.nodes('Datos/Usuarios/usuario') T(z)
) result;

      --AHORA CARGUEMOS LOS Empleados 








END
GO


