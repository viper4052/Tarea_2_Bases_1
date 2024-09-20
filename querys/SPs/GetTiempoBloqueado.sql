USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Retorna desde cuanto le falta al 
boton de login para poder ser activado 
de nuevo*/

--  Descripcion de parametros: 

--  @OutResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @OutTime: dice cuanto tiempo le falta de bloqueo al boton de login  

ALTER PROCEDURE [dbo].[GetTiempoBloqueado]
	@OutResultCode INT OUTPUT
	, @OutTime INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 

	DECLARE @LastBlock DATETIME
	SELECT TOP 1 @LastBlock = PostTime 
	FROM dbo.BitacoraEvento
	WHERE IdTipoEvento = 3
	ORDER BY PostTime DESC; 

	SELECT @OutTime = DATEDIFF(MINUTE, @LastBlock, GETDATE());
	select @OutTime as oout;

	SET @OutResultCode = 0;

	END TRY 

	BEGIN CATCH 
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
	SET @OutResultCode = 50008;

	END CATCH 



	SET NOCOUNT OFF;
END;