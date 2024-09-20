USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dado un evento trata de insertarlo en la base 
de datos en caso de poder da un outresultcode de 0
si falla da uno de error de BD 50008*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InTipoEvento: da el tipo de evento para así buscar su id
--  @InDescripcion: Ingresa la descripcion del evento
--  @InUsername: da el nombre del usuario con el buscaremos cual su Id
--  @InPostInIP: Ingresa la IP desde donde ocurrio

ALTER PROCEDURE [dbo].[IngresarBitacora]
	@OutResultCode INT OUTPUT 
	, @InTipoDeEvento VARCHAR(128)
	, @InDescripcion VARCHAR(256)
	, @InUsername VARCHAR(128)
	, @InPostInIP VARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	
		
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
			(SELECT Id 
			  FROM dbo.TipoEvento
			  WHERE Nombre = @InTipoDeEvento)
			, @InDescripcion 
			, (SELECT Id 
				FROM dbo.Usuario
				WHERE Username = @InUsername)
			, @InPostInIP 
			, GETDATE()
		)		
		SET @OutResultCode = 0; 
	END TRY
	BEGIN CATCH
		-- si no se logra insertar se denomina como error de la BD
		SET @OutResultCode = 50008;
	END CATCH;
END;


