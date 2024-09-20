USE [tarea2BD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--
--  Dado un codigo de error devuelve la descripicion del mismo 
  
--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @outDescripcion: aqui se dejara el valor de al descripcion 
--  @InCodigo:


ALTER PROCEDURE [dbo].[BuscaTipoDeError]
    @OutResulTCode INT OUTPUT
	, @OutDescripcion VARCHAR(128) OUTPUT
	, @InCodigo INT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY 
	SET @OutResulTCode = 0;

    --Primero por si acaso revisaremos si el codigo existe
	IF EXISTS  
	(
		SELECT Codigo FROM dbo.Error
		WHERE Codigo = @InCodigo
	)
	BEGIN 
		SELECT @OutDescripcion = Descripcion FROM dbo.Error
        WHERE Codigo = @InCodigo;
	END 
	ELSE
		SET @OutResulTCode = 50008;  --si no se encuentra el codigo de 
									  -- es un error de BD 
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
		SET @OutResulTCode = 50008;
	END CATCH 
    SET NOCOUNT OFF;
END;
GO