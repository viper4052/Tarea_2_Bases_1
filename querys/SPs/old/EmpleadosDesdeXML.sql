USE [tarea2BD]
GO

/****** Object:  StoredProcedure [dbo].[MovimientosDesdeXML]    Script Date: 21/09/2024 23:18:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* Dado un empleado del xml, se inserta en empleado mediante 
IngresarEmpleado y luego el resultado se guarda en bitacora*/

--	Descripción de parámetros: 
--	@OutResultCode: Código de resultado de ejecución. 0 Corrio sin errores.
--	@InDocID: Documento de identidad del empleado.
--	@InPuesto: Tipo de Puesto Del empleado
--	@InNombre: nombre del empleado
--	@InFechaContratacion: Fecha cuando ocurrio


ALTER PROCEDURE dbo.EmpleadosDesdeXML
	@OutResultCode INT OUTPUT 
	, @InPuesto VARCHAR(32)
	, @InNombre VARCHAR(32)
	, @InDocID INT 
	, @InFechaContratacion DATE
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION 

	--Primero tratamos de insertar el valor en Movimiento
	EXEC dbo.IngresarEmpleado @OutResultCode = @OutResultCode OUTPUT
								, @InPuesto = @InPuesto
								, @InNombre = @InNombre
								, @InDocID = @InDocID
								, @InFechaContratacion = @InFechaContratacion
	

	--Ahora ingresemos lo ocurrido en bitacora 

	--Aqui se monta la descripicion 
	DECLARE @TipoEvento VARCHAR(32);
	DECLARE @Descripcion VARCHAR(128);
	IF(@OutResultCode <> 0)  --si fue error
		BEGIN
			SET @Descripcion = 
			(SELECT Descripcion FROM dbo.Error 
			 WHERE Codigo = @OutResultCode)
			 + ',';
			SET @TipoEvento = 'Insercion no exitosa';
		END;
	ELSE       --si fue exitoso
		BEGIN
		SET @TipoEvento = 'Insercion exitosa';		
		END; 

	SET @Descripcion = 
		CONVERT(VARCHAR(8), @InDocID) 
		+ ',' +
		@InNombre
		+ ',' +
		@InPuesto;	


	DECLARE @PostTime DATETIME
	SET @PostTime = GETDate()

	--se guarda en bitacora 
	EXEC dbo.IngresarBitacora @OutResultCode = @OutResultCode OUTPUT
							  , @InTipoDeEvento = @TipoEvento
							  , @InDescripcion = @Descripcion 
							  , @InUsername = 'CARGAXML'
							  , @InPostInIP = '::1'
							  , @InPostTime = @PostTime
	
	IF @OutResultCode <> 0
	BEGIN
		THROW 50008, 'Error de base de datos', 1;
	END
	
	SET @OutResultCode = 0; 

	COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		-- si no se logra insertar se denomina como error de la BD
		ROLLBACK TRANSACTION;
		SET @OutResultCode = 50008;
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


GO


