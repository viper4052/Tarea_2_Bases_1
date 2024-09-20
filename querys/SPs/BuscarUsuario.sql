USE [tarea2BD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--
--  Revisa si un usuario esta en la base de datos, junto con sus datos correctos
  
--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InUsername: el Nombre de usuario que vamos a buscar
--  @InPassword: la contraseña que vamos a buscar

ALTER PROCEDURE [dbo].[BuscarUsuario]
    @OutResulTCode INT OUTPUT
	, @InUsername VARCHAR(128)
	, @InPassword VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY 
	SET @OutResulTCode = 0;
    --Primero revisemos si el usuario existe
	IF NOT EXISTS
	(
		SELECT Username FROM dbo.Usuario
		WHERE Username = @InUsername
	)
	BEGIN 
		SET @OutResulTCode = 50001;
	END 
	-- Si el usuario existe ahora ver si la contrasenna corresponde
	ELSE
		IF NOT EXISTS
		(
			SELECT Username FROM dbo.Usuario
			WHERE Username = @InUsername AND Pass = @InPassword
		)
		BEGIN 
			SET @OutResulTCode = 50002;
		END 
		ELSE
			SET @OutResulTCode = 0;

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


-- Esto es para probarlo
/*
DECLARE @R INT;
EXEC [dbo].[BuscarUsuario]
    @InUsername = 'UsuarioScripts',
    @InPassword = 's',
    @OutResulTCode = @R OUTPUT;
SELECT @R AS OutResulTCode;*/
