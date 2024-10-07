USE [tarea2BD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[EliminaEmpleado]
	/*
		Elimina de forma logica, solo asigna el valor de la columna
		EsActivo a 0, y no elimina de la base de datos.
	
	*/
	@OutResulTCode INT OUTPUT
	, @InRefName VARCHAR(128)
    , @InUsername VARCHAR(128)
    , @InPostInIP VARCHAR(128)
    , @InPostTime DATETIME
	, @InConfirmacion INT --dice si si se confirma el borrado

	AS
	BEGIN
	SET NOCOUNT ON;
    BEGIN TRY

	DECLARE @Descripcion VARCHAR(256)
			, @Puesto VARCHAR(16)
			, @ValorDoc INT
			, @Saldo MONEY
			, @IdEvento INT;

	SET @OutResulTCode = 0;

	SELECT @Puesto = P.Nombre
	FROM dbo.Empleado E
	INNER JOIN dbo.Puesto P ON E.IdPuesto = P.Id
	WHERE E.Nombre = @InRefName;

	SELECT @ValorDoc = E.ValorDocumentoIdentidad
	FROM dbo.Empleado E
	WHERE E.Nombre = @InRefName;

	SELECT @Saldo = E.SaldoVacaciones
	FROM dbo.Empleado E
	WHERE E.Nombre = @InRefName;

	SET @Descripcion = CONVERT(VARCHAR(32),@ValorDoc)
					   +','+ @InRefName
					   +','+ @Puesto

	IF(@InConfirmacion = 0)
	BEGIN 

	SELECT @IdEvento = TE.Id 
	FROM dbo.TipoEvento TE
	WHERE TE.Nombre = 'Intento de borrado';
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
		, (SELECT U.Id 
		   FROM dbo.Usuario U
		   WHERE U.Username = @InUsername )
		, @InPostInIP
		, @InPostTime
	)

	END
	ELSE
	BEGIN
	SET @Descripcion = @Descripcion 
					   +','+ CONVERT(VARCHAR(32),@Saldo);
	

	SELECT @IdEvento = TE.Id 
	FROM dbo.TipoEvento TE
	WHERE TE.Nombre = 'Borrado exitoso';

	BEGIN TRANSACTION;
	
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
		, (SELECT U.Id 
		   FROM dbo.Usuario U
		   WHERE U.Username = @InUsername )
		, @InPostInIP
		, @InPostTime
	)

	UPDATE [dbo].[Empleado] WITH (ROWLOCK)
	SET EsActivo = 0
	WHERE Empleado.Nombre = @InRefName

	COMMIT TRANSACTION;
	END;


	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT >0)
		BEGIN
		ROLLBACK;
		END;

		INSERT INTO [dbo].[DBError] VALUES 
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
		SET @OutResulTCode = 50008;
				
	END CATCH;

    RETURN;
END;