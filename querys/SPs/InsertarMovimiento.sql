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
	, @InEmpleado VARCHAR(32)
	, @InMonto MONEY
	, @InUserName VARCHAR(128)
	, @InPostInIP VARCHAR(128)
	, @InPostTime DATETIME 
	, @InNombreMovimiento VARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
	SET @OutResultCode = 0;
	DECLARE @CredODeb VARCHAR(128)
			, @NuevoSaldo MONEY
			, @IdEvento INT
			, @Descripcion VARCHAR(256)
			, @IdUser INT;

	
	--seleccionamos el id del usuario 
	SELECT @IdUser = U.Id FROM dbo.Usuario U
	WHERE U.Username = @InUserName;
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
	END;


	SET @Descripcion = CONVERT(VARCHAR(8), (SELECT E.ValorDocumentoIdentidad 
											FROM dbo.Empleado E
											WHERE E.Nombre = @InEmpleado))
						   + ',' + @InEmpleado
						   + ',' + CONVERT(VARCHAR(16),@NuevoSaldo)
						   + ',' + @InNombreMovimiento
						   + ',' + CONVERT(VARCHAR(16),@InMonto);

	


	IF(@OutResultCode <> 0) --si esto se activa 
	BEGIN                   --significa que fue que no se puede insertar
		 
		 SET @Descripcion = (SELECT Er.Descripcion 
							FROM dbo.Error Er--seleccionamos cual tipo de error fue 
							WHERE codigo = @OutResultCode) 
							+ ',' + @Descripcion
		
		INSERT INTO dbo.BitacoraEvento
		(
			IdTipoEvento
			, Descripcion
			, IdPostByUser
			, PostInIP
			, PostTime
		)
		VALUES 
		(
			@IdEvento
			, @Descripcion
			, @IdUSer
			, @InPostInIP	
			, @InPostTime
		)

	END;
	ELSE --si todo bien entonces insertamos en movimiento y bitacora
	BEGIN
	BEGIN TRANSACTION
	--Insertamos en Movimiento 
		INSERT INTO dbo.Movimiento
		(
			IdEmpleado
			, IdTipoMovimiento
			, Monto
			, NuevoSaldo
			, IdPostByUser
			, PostInIP
			, PostTime
		)
		VALUES 
		(
			(SELECT E.Id 
			FROM dbo.Empleado E
			WHERE E.Nombre = @InEmpleado)
			, (SELECT TM.Id 
			FROM dbo.TipoMovimiento TM
			WHERE TM.Nombre = @InNombreMovimiento)
			, @InMonto
			, @NuevoSaldo
			, @IdUser
			, @InPostInIP	
			, @InPostTime
		)

		INSERT INTO dbo.BitacoraEvento
		(
			IdTipoEvento
			, Descripcion
			, IdPostByUser
			, PostInIP
			, PostTime
		)
		VALUES 
		(
			@IdEvento
			, @Descripcion
			, @IdUSer
			, @InPostInIP	
			, @InPostTime
		)

		UPDATE dbo.Empleado WITH (ROWLOCK)
		SET SaldoVacaciones = @NuevoSaldo
		WHERE Nombre = @InEmpleado;
	COMMIT TRANSACTION;
	END;
	
	END TRY 
	BEGIN CATCH 
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
