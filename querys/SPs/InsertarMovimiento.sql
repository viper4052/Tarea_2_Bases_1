USE [tarea2BD]
GO
/****** Object:  StoredProcedure [dbo].[InsertarMovimiento]    Script Date: 05/10/2024 10:39:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* Dados datos para crear un movimiento si intentara
annadir a la tabla de movimientos y restar el saldo 
correspondiente al usuario, solo que */

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InEmpleado: da el nombre del empleado 
--  @InMonto: da el monto a sumar o rebajar 
--  @InUsername: da el nombre del usuario con el buscaremos cual su Id
--	@InPostInIP: da la ip del cambio
--	@InPostTime: da la dattime del cambio
--  @InNombreMovimiento: dice si es credito o debito 

ALTER PROCEDURE [dbo].[InsertarMovimiento]
	@OutResultCode INT OUTPUT
	, @InEmpleado INT
	, @InMonto MONEY
	, @InUserName VARCHAR(128)
	, @InPostInIP VARCHAR(128)
	, @InPostTime DATETIME 
	, @InNombreMovimiento VARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
	
	DECLARE @CredODeb VARCHAR(128)
			, @NuevoSaldo MONEY
			, @IdEvento INT
			, @Descripcion VARCHAR(256)


	--selecionamos que tipo de movimiento 
	SELECT @CredODeb = TipoDeAccion FROM dbo.TipoMovimiento
	WHERE Nombre = @InNombreMovimiento;

	--vemos cuanto saldo tiene el empleado en este momento
	SELECT @NuevoSaldo = E.SaldoVacaciones
	FROM dbo.Empleado E
	WHERE E.Nombre = @InEmpleado; 

	-- seleccionamos que estamos tratando de insertar movimiento 
	SELECT @IdEvento = TE.id FROM dbo.TipoEvento TE --dejamos lista la Id de Inserta Empleado
	WHERE TE.Nombre ='Insertar movimiento exitoso';
	
	--vemos si hay que restar o no 
	IF (@CredODeb = 'Credito')
	BEGIN
		SET @NuevoSaldo += @InMonto;
	END;
	ELSE 
	BEGIN 
		SET @NuevoSaldo -= @InMonto;
	END;


	--si es negativo arrojamos error 
	IF(@NuevoSaldo < 0)
	BEGIN
			SET @OutResultCode = 50011;
			SELECT @IdEvento = TE.Id 
			FROM dbo.TipoEvento TE
			WHERE TE.Nombre = 'Intento de insertar movimiento';
			THROW @ResultCode, 'Monto del movimiento rechazado pues si se aplicar el saldo seria negativo.', 0;
	END;


	SET @Descripcion = CONVERT(VARCHAR(8), (SELECT E.ValorDocumentoIdentidad 
											FROM dbo.Empleado E
											WHERE E.Nombre = @InEmpleado))
						   + ',' + @InEmpleado
						   + ',' + CONVERT(VARCHAR(16),@NuevoSaldo)
						   + ',' + @InNombreMovimiento
						   + ',' + CONVERT(VARCHAR(16),@InMonto);

	
	BEGIN TRANSACTION

	COMMIT TRANSACTION;

	
	END TRY 
	BEGIN CATCH 
	ROLLBACK TRANSACTION; 


	SELECT @OutResultCode as Result; 

	IF @@TRANCOUNT > 0 
	BEGIN 
	ROLLBACK; 
	END; 


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
	SET @OutResultCode = 50011; --error de saldo quedaria negativo  

	END CATCH 

	SET NOCOUNT OFF;
END; 
