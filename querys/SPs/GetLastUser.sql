USE [tarea2BD]
GO

/****** Object:  StoredProcedure [dbo].[BuscarUsuario]    Script Date: 29/09/2024 12:33:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--
--  Revisa si un usuario esta en la base de datos, junto con sus datos correctos
  
--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @OutUserName: retorna el nombre del usuario que hizo el ultimo login

ALTER PROCEDURE [dbo].[GetLastUser]
    @OutResulTCode INT OUTPUT
	, @OutUserName VARCHAR(128) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY 
	SET @OutResulTCode = 0;
    --Primero revisemos si el usuario existe
	DECLARE @UserId INT
	SELECT TOP 1 @UserId = IdPostByUser FROM dbo.BitacoraEvento
	WHERE IdTipoEvento = 1 
	ORDER BY PostTime DESC;

	SELECT @OutUserName = Username
	FROM dbo.Usuario
	WHERE Id = @UserId; 

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
	SET @OutResulTCode = 50008
	END CATCH 

    SET NOCOUNT OFF;
END;
GO


