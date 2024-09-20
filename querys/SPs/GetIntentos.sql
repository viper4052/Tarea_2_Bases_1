USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dado un usuario revisa cuando fue la ultima vez que 
hizo un login no exitoso y devuelve cuantos intentos
lleva en los ultimos 30 minutos.
Si ya pasaron más de 30 minutos entonces se reinician
los intentos.*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @outIntentos: da el numero de intentos 
--  @InTipoEvento: da el tipo de evento para así buscar su id
--  @InUsername: da el nombre del usuario con el buscaremos cual su Id

ALTER PROCEDURE [dbo].[GetIntentos]
	@OutResultCode INT OUTPUT
	, @OutIntentos INT OUTPUT
	, @InUsername VARCHAR(128)
	, @InTipoEvento VARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SET @OutIntentos = 1;
		SET @OutResultCode = 0; 

		DECLARE @IdUser INT;
		SELECT @IdUser = Id FROM dbo.Usuario
		WHERE @InUsername = Username;--esto nos va a dar el id usuario
									 -- con el que estamos trabajando

		DECLARE @IdEvento INT;
		SELECT @IdEvento = Id FROM dbo.TipoEvento
		WHERE @InTipoEvento = Nombre;  -- el id del tipo de evento 


		DECLARE @UltimaFecha DATETIME
		SELECT TOP 1 @UltimaFecha = PostTime --solo se seleciona 1 ya que estan indexados DESC
		FROM dbo.BitacoraEvento
		WHERE @IdEvento = IdTipoEvento AND @IdUser = IdPostByUser
		ORDER BY PostTime DESC;




		IF @UltimaFecha IS NULL
        BEGIN
            SET @OutIntentos = 1;
        END;
       
		ELSE
		BEGIN

			DECLARE @Descripcion VARCHAR(256);
			SELECT TOP 1 @Descripcion = Descripcion 
			FROM dbo.BitacoraEvento --solo se seleciona 1 ya que estan indexados DESC
			WHERE @IdEvento = IdTipoEvento AND @IdUser = IdPostByUser
			ORDER BY PostTime DESC;

			DECLARE @Intentos INT --en esa posicion esta el numero de intentos 
			SELECT @Intentos = CAST(SUBSTRING(@Descripcion, 1, 1) AS INT);

			DECLARE @Dif INT
			SELECT @Dif = DATEDIFF(MINUTE, @UltimaFecha, GETDATE());

			
			
			IF(@Dif > 20)
				BEGIN
					SET @Intentos = 1;
				END;
			ELSE
				BEGIN
					SET @OutIntentos = @Intentos + 1 ;
				END;

			IF(@OutIntentos > 4)-----------
				BEGIN
					SET @OutResultCode = 50003; 
				END;  
		END;
	END TRY
	BEGIN CATCH
		-- si no se logra insertar se denomina como error de la BD
		SET @OutResultCode = 50008;
	END CATCH;

	SET NOCOUNT OFF;
END;


