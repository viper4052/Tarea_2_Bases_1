USE [tarea2BD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ConsultarEmpleado]
	@OutResulTCode INT OUTPUT
	, @OutSaldo MONEY OUTPUT
	, @OutDocId INT OUTPUT
	, @OutPuesto VARCHAR(16) OUTPUT
	, @InName VARCHAR(128)
    , @InUsername VARCHAR(128)
    , @InPostInIP VARCHAR(128)
    , @InPostTime DATETIME

	AS
	BEGIN
	SET NOCOUNT ON;
    BEGIN TRY

	SET @OutResulTCode = 0;

	SELECT @OutPuesto = P.Nombre
	FROM dbo.Empleado E
	INNER JOIN dbo.Puesto P ON E.IdPuesto = P.Id
	WHERE E.Nombre = @InName;

	SELECT @OutDocId = E.ValorDocumentoIdentidad
	FROM dbo.Empleado E
	WHERE E.Nombre = @InName;

	SELECT @OutSaldo = E.SaldoVacaciones
	FROM dbo.Empleado E
	WHERE E.Nombre = @InName;


	END TRY
	BEGIN CATCH

		SET @OutResulTCode = 50008;
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
		
				
	END CATCH;

    RETURN;
END;
