USE [tarea2BD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	El nombre original del Empleado va a ser la referencia principal para toda edicion
	de informacion. Por eso es la ultima variable en verificar si es NOT NULL.

	Pregunta si las demas variables no estan nulas para saber cuales editar,
	porque podria no editar las 3 al mismo tiempo.

--  Dado un codigo de error devuelve la descripicion del mismo 
  
--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @OutMensajeError: aqui se dejara el mensaje de error (en caso de haberlo)
--  @InRefName: nombre de referencia original de empleado
--  @InNewIdPuesto: aqui el posible nuevo ID de puesto de empleado
--  @InNewNombre: aqui el posible nuevo NOMBRE de empleado
--  @InNewValorDocumentoIdentidad: aqui el posible nuevo valor de documento de identidad del empleado
--  @InPost: aqui el IP de donde se realizo la solicitud 
--  @InPostTime: aqui el momento en el que se hizo la consulta 
*/

ALTER PROCEDURE [dbo].[EditaEmpleado]
    @OutResulTCode INT OUTPUT
	, @InRefName VARCHAR(128)
	, @InNewPuesto VARCHAR(128)
	, @InNewNombre VARCHAR(128)
	, @InNewValorDocumentoIdentidad INT
	, @InUsername VARCHAR(128)
	, @InPostInIP VARCHAR(128)
	, @InPostTime DATETIME 
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @OutResulTCode = 0;

        -- Variables de inserción a bitácora
        DECLARE @TipoDeEvento VARCHAR(128),
                @Descripcion VARCHAR(256),
                @IdUser INT,
                @IdEvento INT,
                @IdPuesto INT,
                @newValorDocID INT,
                @newPuesto VARCHAR(16),
                @newNombre VARCHAR(32);
		
		

		SELECT @newPuesto = P.Nombre
		FROM dbo.Empleado E
		INNER JOIN dbo.Puesto P ON E.IdPuesto = P.Id
	 	WHERE E.Nombre = @InRefName;

		SELECT @newValorDocID = E.ValorDocumentoIdentidad
		FROM dbo.Empleado E
		WHERE E.Nombre = @InRefName
		
		

		SELECT @newNombre = E.Nombre
		FROM dbo.Empleado E
		WHERE E.Nombre = @InRefName
		
		
		

		SET @Descripcion = @newNombre
							+','+CONVERT(VARCHAR(8), @newValorDocID)
							+','+@newPuesto;
	
		

		
		
		
		IF @InNewPuesto IS NOT NULL
		BEGIN
		SELECT @IdPuesto = P.ID
		FROM dbo.Puesto P
		WHERE P.Nombre = @InNewPuesto
		SET @newPuesto = @InNewPuesto
		END;
		ELSE
		BEGIN
		SELECT @IdPuesto = P.ID
		FROM dbo.Puesto P
		WHERE P.Nombre = @newPuesto
		END;


		
		

		IF @InNewValorDocumentoIdentidad IS NOT NULL
		BEGIN
		SET @newValorDocID = @InNewValorDocumentoIdentidad
		END;



		IF @InNewNombre IS NOT NULL
		BEGIN
		SET @newNombre = @InNewNombre
		END;


		
		
		SET @Descripcion = @Descripcion 
						   +','+ @newNombre
						   +','+ @newPuesto
						   +','+ CONVERT(VARCHAR(8), @newValorDocID)
						   +','+ CONVERT(VARCHAR(16),(SELECT E.SaldoVacaciones 
								  FROM dbo.Empleado E
								  WHERE E.Nombre = @InRefName))
	


	IF EXISTS(SELECT * FROM dbo.Empleado E
			  WHERE ValorDocumentoIdentidad = @InNewValorDocumentoIdentidad)
	BEGIN
		SET @OutResulTCode = 50006;

		SELECT @IdEvento = TE.Id 
		FROM dbo.TipoEvento TE
		WHERE TE.Nombre = 'Update no exitoso';
	END 

	IF EXISTS(SELECT * FROM dbo.Empleado E
			  WHERE E.Nombre = @InNewNombre)
	BEGIN
		SET @OutResulTCode = 50007;

		SELECT @IdEvento = TE.Id 
		FROM dbo.TipoEvento TE
		WHERE TE.Nombre = 'Update no exitoso';
	END 


	IF(@OutResulTCode <> 0)
	BEGIN 

		SET @Descripcion = (SELECT Er.Descripcion 
							FROM dbo.Error Er
							WHERE Er.codigo = @OutResulTCode)
							+ ','+
							@Descripcion;

		
		
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
			, (SELECT U.id from dbo.Usuario U
			   WHERE U.Username	= @InUsername)
			, @InPostInIP	
			, @InPostTime
		)

	END;
	ELSE

	BEGIN
	BEGIN TRANSACTION	

		IF @InNewPuesto IS NOT NULL
		BEGIN
		UPDATE dbo.Empleado WITH (ROWLOCK) 
		SET IdPuesto = @IdPuesto
		WHERE Nombre = @InRefName;
		END;

		IF @InNewValorDocumentoIdentidad IS NOT NULL
		BEGIN
		UPDATE dbo.Empleado WITH (ROWLOCK) 
		SET ValorDocumentoIdentidad = @InNewValorDocumentoIdentidad
		WHERE Nombre = @InRefName;
		END;

		IF @InNewNombre IS NOT NULL
		BEGIN
		UPDATE dbo.Empleado WITH (ROWLOCK) 
		SET Nombre = @InNewNombre
		WHERE Nombre = @InRefName;
		END;

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
			(SELECT TE.Id from dbo.TipoEvento TE
			   WHERE TE.Nombre	= 'Update exitoso')
			, @Descripcion
			, (SELECT U.id from dbo.Usuario U
			   WHERE U.Username	= @InUsername)
			, @InPostInIP	
			, @InPostTime
		)

        
		COMMIT TRANSACTION;
    END;

    END TRY

    BEGIN CATCH

		IF(@@TRANCOUNT > 0)
		BEGIN
		ROLLBACK;
		END;


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

               
    END CATCH;

    RETURN;
END;
