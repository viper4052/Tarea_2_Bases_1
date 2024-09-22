USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dados datos para un empleado se inserta a dbo.empleado
y depdendiendo puede arrojar error si ya el valordocid existe
o el nombre*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InPuesto: da el tipo de puesto, en nombre luego busacr ID
--  @InNombre: Ingresa el nombre del empelado
--  @InDocID : da el valor del documento de identidad
--  @InFechaContratacio: da la fecha en la que se contrato el empleado

ALTER PROCEDURE [dbo].[IngresarEmpleado]
	@OutResultCode INT OUTPUT 
	, @InPuesto VARCHAR(128)
	, @InNombre VARCHAR(256)
	, @InDocID INT 
	, @InFechaContratacion DATE
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		IF EXISTS (SELECT ValorDocumentoIdentidad
					FROM Empleado
					WHERE ValorDocumentoIdentidad =@InDocID)
		BEGIN
			SET @OutResultCode = 50004;
			THROW 50004, 'Empleado con ValorDocumentoIdentidad ya existe en inserción',1;
		END; 

		IF EXISTS (SELECT Nombre
					FROM Empleado
					WHERE Nombre =@InNombre)
		BEGIN
			SET @OutResultCode = 50005;
			THROW 50005, 'Empleado con mismo nombre ya existe en inserción',1;
		END; 

		
		INSERT dbo.Empleado
		(
			IdPuesto
			, Nombre
			, ValorDocumentoIdentidad
			, FechaContratacion
		)
		Values 
		(
			(SELECT Id FROM dbo.Puesto
			WHERE Nombre = @InPuesto)
			, @InNombre 
			, @InDocID
			, @InFechaContratacion
		);
		
		
		SET @OutResultCode = 0; 
	END TRY
	BEGIN CATCH
		-- si no se logra insertar se denomina como error de la BD
		INSERT INTO dbo.DBError VALUES 
		(
            SUSER_SNAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );
	END CATCH;
END;


