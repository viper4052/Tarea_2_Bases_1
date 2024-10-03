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
--  @OutMensajeError: aqui se dejara el mensaje de error (en caso de haberlo)
--  @OutIntentos: retorna si se cancelo el login 
--  @InUsername: aqui el posible username del usuario con el que estamos trabajando 
--  @InPassword: aqui el posible password del usuario con el que estamos trabajando 
--  @InPostInIP: aqui el IP de donde se realizo la solicitud 
--  @InPostTime: aqui el momento en el que se hizo la consulta 


ALTER PROCEDURE [dbo].[Login]
    @OutResulTCode INT OUTPUT
	, @OutMensajeError VARCHAR(128) OUTPUT
	, @OutIntentos INT OUTPUT
	, @InUsername VARCHAR(128)
	, @InPassword VARCHAR(128)
	, @InPostInIP VARCHAR(128)
	, @InPostTime DATETIME 


AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY 


	SET @OutResulTCode = 0;
	SET @OutIntentos = 1;
	SET @OutMensajeError = ' ';
	DECLARE @TipoDeEvento VARCHAR(128)
			, @Descripcion VARCHAR(128)
			, @Intento INT
			, @IdUser INT 
			, @IdEvento INT
			, @DescripcionTRE VARCHAR(128)--esta variable es para la descripcion en login desabilitado
			, @IdEventoRE INT--esta variable es para el tipoDeEvento en login desabilitado
			, @TipoEventoRE VARCHAR(128)--esta variable es para el tipoDeEvento en login desabilitado
	

		
    --Primero por si acaso revisaremos si el codigo existe
	IF NOT EXISTS
	(
		SELECT Username FROM dbo.Usuario
		WHERE Username = @InUsername
	)
	BEGIN 
		SET @OutResulTCode = 50001;
		SET @TipoDeEvento = 'Login No exitoso';
		SET @InUsername = 'LOGINFALLIDO';
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
			SET @TipoDeEvento = 'Login No exitoso'
		END 
		ELSE 
		BEGIN 
			SET @TipoDeEvento = 'Login Exitoso'
			SET @Descripcion = ' ';
		END 
		
	
	--Ahora toca revisar si se genero un error
	--en ese caso crear el mensaje de error 

	IF (@OutResulTCode <> 0)
	BEGIN 
		SELECT @OutMensajeError = Descripcion 
		FROM dbo.Error
		WHERE Codigo = @OutResulTCode; 
	END; 


	--Ya que @InUsername de fijo existe y @TipoDeEvento tambien
	--saquemos sus Ids 
	SELECT @IdUser = Id FROM dbo.Usuario
	WHERE @InUsername = Username;--esto nos va a dar el id usuario
									 -- con el que estamos trabajando
	
	SELECT @IdEvento = Id FROM dbo.TipoEvento
	WHERE @TipoDeEvento = Nombre;  -- el id del tipo de evento


	--Ahora, tambien en caso de error toca buscar 
	--cuantos intentos lleva 
	IF (@OutResulTCode <> 0)
	BEGIN 
		
		
		--seleccionaremos el total de intentos 
		SELECT @Intento = COUNT(*) 
		FROM dbo.BitacoraEvento --solo se seleciona 1 ya que estan indexados DESC
		WHERE @IdEvento = IdTipoEvento AND @IdUser = IdPostByUser 
		AND @InPostTime >= DATEADD(MINUTE, -20, GETDATE());
		
		--Ya con esos datos podemos buscar cuantos intentos lleva
		SET @Intento += 1 --le sumamos uno a la cantidad de intentos actual
		
		--ahora formemos la descripcion de error
		SET @Descripcion = CONVERT(VARCHAR(1), @Intento)+','+CONVERT(VARCHAR(5), @OutResulTCode)


		--ahora saquemos cuantos intentos han habido
		--En los ultimos 30 minutos 

		SELECT Descripcion 
		FROM dbo.BitacoraEvento --solo se seleciona 1 ya que estan indexados DESC
		WHERE @IdEvento = IdTipoEvento AND @IdUser = IdPostByUser 
		AND @InPostTime >= DATEADD(MINUTE, -30, GETDATE());

		SET @OutIntentos = @@ROWCOUNT; 

		IF (@OutIntentos > 3)
		BEGIN
			
			SET @OutIntentos = 0; -- SI se bloquea el login se manda 0

			SET @DescripcionTRE = ' '; 

			SET @TipoEventoRE = 'Login deshabilitado';
			
			SELECT @IdEventoRE = Id FROM dbo.TipoEvento
			WHERE @TipoEventoRE = Nombre;  -- el id del tipo de evento
			SET @OutResulTCode = 50003; 

		END;
		ELSE 
		BEGIN 
			SET @OutIntentos = 1; -- SI se no bloquea el login se manda 1
		END;

		--ponemos en @outIntentos cuantas filas se seleccionaron 
		
	END; 

	--Una vez ya verificado si el usuario existe 
	--ingresemos a bitacora el resultado 
	
	BEGIN TRANSACTION  
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
			, @IdUser
			, @InPostInIP 
			, @InPostTime
		)

	
	IF (@OutIntentos = 0)
	BEGIN 
			
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
			@IdEventoRE 
			, @DescripcionTRE  
			, @IdUser
			, @InPostInIP 
			, @InPostTime
		)

		SELECT @OutMensajeError = Descripcion 
		FROM dbo.Error
		WHERE Codigo = @OutResulTCode; 
				

	END 

	COMMIT TRANSACTION;
						   
	END TRY 

	BEGIN CATCH 

	ROLLBACK; 
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
		
		SELECT @OutMensajeError = Descripcion 
		FROM dbo.Error
		WHERE Codigo = @OutResulTCode; 


	END CATCH 
    SET NOCOUNT OFF;
END;
GO