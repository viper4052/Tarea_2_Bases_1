USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dado un movimiento, se inserta en movimientos mediante 
InsertarMovimiento y luego el resultado se guarda en bitacora*/

--	Descripción de parámetros: 
--	@OutResultCode: Código de resultado de ejecución. 0 Corrio sin errores.
--	@InValorDocId: Documento de identidad del empleado.
--	@InIdTipoMovimiento: Tipo de movimiento a registrar.
--	@InMonto: Monto del movimiento.
--	@InPostByUser: Usuario que realiza la operación.
--	@InPostInIP: ip desde donde se realiza la operación.
--	@InPostTime: Fecha y hora de la operación.


ALTER PROCEDURE [dbo].[MovimientosDesdeXML]
	@OutResultCode INT OUTPUT 
	, @InValorDocId INT
	, @InIdTipoMovimiento VARCHAR(128)
	, @InMonto MONEY
	, @InPostByUser VARCHAR(128)
	, @InPostInIP VARCHAR(128)
	, @InPostTime DATETIME
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

	--Primero tratamos de insertar el valor en Movimiento
	EXEC dbo.InsertarMovimiento @OutResultCode = @OutResultCode OUTPUT
								, @InDocIdEmpleado = @InValorDocId
								, @InMonto = @InMonto
								, @InUsername = @InPostByUser
								, @InPostInIP = @InPostInIP
								, @InPostTime = @InPostTime 
								, @InNombreMovimiento = @InIdTipoMovimiento
	

	--Ahora ingresemos lo ocurrido en bitacora 

	DECLARE @NombreE VARCHAR(20), @Saldo MONEY

	SELECT @NombreE = E.Nombre, @Saldo = E.SaldoVacaciones FROM dbo.Empleado E
	WHERE E.ValorDocumentoIdentidad = @InValorDocId;


	DECLARE @TipoEvento VARCHAR(32);


	--Aqui se monta la descripicion 
	DECLARE @Descripcion VARCHAR(128)
	IF(@OutResultCode = 50011)  --si fue error
		BEGIN
			SET @Descripcion = 
			(SELECT Descripcion FROM dbo.Error 
			 WHERE Codigo = @OutResultCode)
			 + ',' +
			CONVERT(VARCHAR(8), @InValorDocId) 
			+ ',' +
			@NombreE
			 + ',' +
			CONVERT(VARCHAR(8), @Saldo) 
			 + ',' +
			 @InIdTipoMovimiento
			 + ',' +
			CONVERT(VARCHAR(8), @InMonto);
			
			SET @TipoEvento = 'Intento de insertar movimiento';
		END;
	ELSE       --si fue exitoso
		BEGIN
			SET @Descripcion = 
			CONVERT(VARCHAR(8), @InValorDocId) 
			+ ',' +
			@NombreE
			 + ',' +
			CONVERT(VARCHAR(8), @Saldo) 
			 + ',' +
			 @InIdTipoMovimiento
			 + ',' +
			CONVERT(VARCHAR(8), @InMonto);		
			SET @TipoEvento = 'Insertar movimiento exitoso';
		END; 


	--se guarda en bitacora 
	EXEC dbo.IngresarBitacora @OutResultCode = @OutResultCode OUTPUT
							  , @InTipoDeEvento = @TipoEvento
							  , @InDescripcion = @Descripcion 
							  , @InUsername = @InPostByUser
							  , @InPostInIP = @InPostInIP
							  , @InPostTime = @InPostTime
	
	SET @OutResultCode = 0; 
	END TRY
	BEGIN CATCH
		-- si no se logra insertar se denomina como error de la BD
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


