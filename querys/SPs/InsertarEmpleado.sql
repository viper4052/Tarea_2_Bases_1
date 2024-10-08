USE [tarea2BD]
GO
/****** Object:  StoredProcedure [dbo].[IngresarEmpleado]    Script Date: 06/10/2024 2:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* Dados datos para un empleado se inserta a dbo.empleado
y depdendiendo puede arrojar error si ya el valordocid existe
o el nombre*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InPuesto: da el tipo de puesto, en nombre luego busacr ID
--  @InNombre: Ingresa el nombre del empelado
--  @InDocID : da el valor del documento de identidad

ALTER PROCEDURE [dbo].[InsertarEmpleado]
	@OutResultCode INT OUTPUT 
	, @InPuesto VARCHAR(16)
	, @InNombre VARCHAR(128)
	, @InDocID INT 
	, @InPostInIp VARCHAR(32) 
	, @InUser VARCHAR(32) 
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SET @OutResultCode = 0; 

		DECLARE @Descripcion VARCHAR(256)
				, @PosTime DATE
				, @IdEvento INT 


				

		SET @PosTime = GETDATE();


		SELECT @IdEvento = TE.id 
		FROM dbo.TipoEvento TE
		WHERE TE.Nombre = 'Insercion exitosa';

		SET @Descripcion = CONVERT(VARCHAR(16), @InDocID)
						    + ',' + @InNombre
						    + ',' + @InPuesto;

		IF EXISTS (SELECT ValorDocumentoIdentidad
					FROM Empleado
					WHERE ValorDocumentoIdentidad =@InDocID)
		BEGIN
			SET @OutResultCode = 50004;
		END; 

		IF EXISTS (SELECT Nombre
					FROM Empleado
					WHERE Nombre =@InNombre)
		BEGIN
			SET @OutResultCode = 50005;
		END; 


	IF(@OutResultCode <> 0) --si esto se activa 
	BEGIN                   --significa que fue que no se puede insertar
		 
		DECLARE @errorM VARCHAR (64);
		SELECT @errorM = Er.Descripcion
		FROM dbo.Error Er
		WHERE Codigo = @OutResultCode;

		SELECT @IdEvento = TE.id 
		FROM dbo.TipoEvento TE
		WHERE TE.Nombre = 'Insercion no exitosa';

		 SET @Descripcion = @errorM + @Descripcion;
		
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
			   WHERE U.Username	= @InUser)
			, @InPostInIP	
			, @PosTime
		)

	END;
	ELSE --si si se puede insertar entonces lo hacemos 
	BEGIN
		BEGIN TRANSACTION 
		INSERT dbo.Empleado
		(
			IdPuesto
			, Nombre
			, ValorDocumentoIdentidad
			, FechaContratacion
		)
		Values 
		(
			(SELECT Id FROM dbo.Puesto
			WHERE Nombre = @InPuesto)
			, @InNombre 
			, @InDocID
			, @PosTime
		);

		

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
			   WHERE U.Username	= @InUser)
			, @InPostInIP	
			, @PosTime
		)
		COMMIT TRANSACTION 
	END;
		
		
	END TRY
	BEGIN CATCH
		-- si no se logra insertar se denomina como error de la BD

	IF @@TRANCOUNT > 0 
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
	END CATCH;
END;


