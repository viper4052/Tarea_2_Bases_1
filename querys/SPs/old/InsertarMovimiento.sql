USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dados datos para crear un movimiento si intentara
annadir a la tabla de movimientos y restar el saldo 
correspondiente al usuario, solo que */

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InDocIdEmpleado: da el documento de identidad del empleado 
--  @InMonto: da el monto a sumar o rebajar 
--  @InUsername: da el nombre del usuario con el buscaremos cual su Id
--	@InPostInIP: da la ip del cambio
--	@InPostTime: da la dattime del cambio
--  @InNombreMovimiento: dice si es credito o debito 

ALTER PROCEDURE [dbo].[InsertarMovimiento]
	@OutResultCode INT OUTPUT
	, @InDocIdEmpleado INT
	, @InMonto MONEY
	, @InUserName VARCHAR(128)
	, @InPostInIP VARCHAR(128)
	, @InPostTime DATETIME 
	, @InNombreMovimiento VARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
	BEGIN TRANSACTION 
	
	DECLARE @CredODeb VARCHAR(128)
	SELECT @CredODeb = TipoDeAccion FROM dbo.TipoMovimiento
	WHERE Nombre = @InNombreMovimiento;

	DECLARE @Estado INT
	SELECT @Estado = EsActivo FROM dbo.Empleado
	WHERE ValorDocumentoIdentidad = @InDocIdEmpleado;

	IF (@Estado = 0)
	BEGIN --Si el usuario no está activo se genera un error para activar el catch
		THROW 50008, 'Error de base de datos',1; --dividir por 0
	END; 

	IF (@CredODeb = 'Credito')
	BEGIN
		UPDATE dbo.Empleado
		SET SaldoVacaciones += @InMonto
		WHERE ValorDocumentoIdentidad = @InDocIdEmpleado;
	END;
	ELSE 
	BEGIN 
		UPDATE dbo.Empleado
		SET SaldoVacaciones -= @InMonto
		WHERE ValorDocumentoIdentidad = @InDocIdEmpleado;
	END;
	

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
	SELECT E.Id
		   , T.Id
		   , @InMonto
		   , E.SaldoVacaciones
		   , U.Id
		   , @InPostInIP
		   , @InPostTime
        FROM dbo.Empleado E 
        INNER JOIN dbo.TipoMovimiento T ON T.Nombre = @InNombreMovimiento
        INNER JOIN dbo.Usuario U ON U.Username = @InUserName
		WHERE E.ValorDocumentoIdentidad = @InDocIdEmpleado;


	SET @OutResultCode = 0;	
	COMMIT TRANSACTION;
	END TRY 
	BEGIN CATCH 
	ROLLBACK TRANSACTION; 

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
GO