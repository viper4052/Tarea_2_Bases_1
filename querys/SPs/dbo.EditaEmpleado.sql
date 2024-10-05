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

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @OutMensajeError: aqui se dejara el mensaje de error (en caso de haberlo)
--  @InRefName: nombre de referencia original de empleado
--  @InNewIdPuesto: aqui el posible nuevo ID de puesto de empleado
--  @InNewNombre: aqui el posible nuebo NOMBRE de empleado
--  @InNewValorDocumentoIdentidad: aqui el posible nuevo valor de documento de identidad del empleado
*/
ALTER PROCEDURE [dbo].[EditaEmpleado]
	@OutResulTCode INT OUTPUT
	, @InRefName VARCHAR(128) /* ESTE ES EL NOMBRE DEL EMPLEADO ANTES DE CUALQUIER EDICION */
	, @InNewIdPuesto INT				= NULL
	, @InNewNombre VARCHAR(128)			= NULL
	, @InNewValorDocumentoIdentidad INT = NULL
	
	AS

		BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResulTCode = 0;
			SET @OutIntentos = 1;
			SET @OutMensajeError = ' ';

			SELECT  Empleado.Nombre
					, Empleado.IdPuesto
					, Empleado.ValorDocumentoIdentidad
			FROM [dbo].[Empleado] E
			WHERE Empleado.Nombre LIKE @InRefName

			-- Variables de insercion a bitacora
			DECLARE @TipoDeEvento VARCHAR(32)
					, @Descripcion VARCHAR(32);
					, @PrevNombre VARCHAR(32) = E.Nombre;
					, @PrevValorDocID INT = E.ValorDocumentoIdentidad;
					, @PrevIdPuesto INT = E.IdPuesto
					, @SaldoActual MONEY = E.SaldoVacaciones

			IF @InNewIdPuesto is not null
				UPDATE [dbo].[Empleado] SET IdPuesto = @InNewIdPuesto 
				WHERE Empleado.Nombre LIKE @InRefName;


			IF @InNewValorDocumentoIdentidad is not null
				UPDATE [dbo].[Empleado] SET ValorDocumentoIdentidad = @InNewValorDocumentoIdentidad 
				WHERE Empleado.Nombre LIKE @InRefName;


			IF @InNewNombre is not null
				UPDATE [dbo].[Empleado] SET Nombre = @InNewNombre 
				WHERE Empleado.Nombre LIKE @InRefName;

			-- Si el update fue exitoso, se inserta en bitacora
			SET @TipoDeEvento = 'Update exitoso';
			SET @Descripcion = @PrevValorDocID + '' + @PrevNombre + '' + @PrevIdPuesto + '|'
			                   + @InNewValorDocumentoIdentidad + '' + @InNewNombre + '' + @InNewIdPuesto + '' + @SaldoActual;
		

			IF( @TipoDeEvento <> ' ')
			BEGIN

			INSERT INTO [dbo].[BitacoraEvento]
					(
						IdTipoEvento
						, Descripcion
					)
			VALUES
			(
				(SELECT Id FROM dbo.TipoEvento
				WHERE Nombre = @TipoDeEvento)
				, @Descripcion
				, (SELECT Id FROM dbo.Usuario
				WHERE Username = @InUsername) 
				, @InIp
				, @InPostTime
			);

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
			
			SELECT @OutMensajeError = Descripcion 
			FROM [dbo].[Error] 
			WHERE Codigo = @OutResulTCode;

			SELECT @OutMensajeError AS OutMensajeError;

			-- Si no logra actualizar el empleado
			SET @TipoDeEvento = 'Update no exitoso';
			SET @Descripcion = @PrevValorDocID + '' + @PrevNombre + '' + @PrevIdPuesto + '|'
			                   + @InNewValorDocumentoIdentidad + '' + @InNewNombre + '' + @InNewIdPuesto + '' + @SaldoActual; 

			-- En el caso que haya actualizado algun valor, devuelve a su valor original
			UPDATE [dbo].[Empleado] 
			SET Nombre = @PrevNombre 
			SET IdPuesto = @PrevIdPuesto
			SET ValorDocumentoIdentidad = @PrevValorDocID
			WHERE Empleado.Nombre LIKE @InRefName;
			
			IF( @TipoDeEvento <> ' ')
			BEGIN

			INSERT INTO [dbo].[BitacoraEvento]
					(
						IdTipoEvento
						, Descripcion
					)
			VALUES
			(
				(SELECT Id FROM dbo.TipoEvento
				WHERE Nombre = @TipoDeEvento)
				, @Descripcion
				, (SELECT Id FROM dbo.Usuario
				WHERE Username = @InUsername) 
				, @InIp
				, @InPostTime
			);
		
		END CATCH

		SET NOCOUNT OFF
	END;