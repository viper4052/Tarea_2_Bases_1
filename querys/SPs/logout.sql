USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dado el nombre del empleado busca algunos de sus datos correspondientes
y los entrega, junto a la lista de todos sus movimientos*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 

CREATE PROCEDURE [dbo].[Logout]
	@OutResultCode INT OUTPUT 
	, @InIp  VARCHAR(16)
	, @InUser VARCHAR(32)
	, @InPostTime DATETIME

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	
	
	SET @OutResultCode = 0;
	DECLARE @IdEvento INT;
	SELECT @IdEvento = TE.Id
	FROM dbo.TipoEvento TE
	WHERE TE.Nombre = 'Logout'


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
	, ' '
	, (SELECT U.Id FROM dbo.Usuario U
	   WHERE U.Username = @InUser)
	, @InIp
	, @InPostTime
	)

		

		
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
