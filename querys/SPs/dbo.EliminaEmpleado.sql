USE [tarea2BD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[EliminaEmpleado]
	/*
		Elimina de forma logica, solo asigna el valor de la columna
		EsActivo a 0, y no elimina de la base de datos.

		No se cual es mas comodo, si con valor de documento de identidad
		o con el nombre unico de empleado
	*/
	@OutResulTCode INT OUTPUT
	, @InRefName VARCHAR(128)
	, @PrevEsActivo INT

	AS
		BEGIN
		SET NOCOUNT ON;
		BEGIN TRY

			SELECT  Empleado.ValorDocumentoIdentidad
					, Empleado.Nombre
					, Empleado.IdPuesto
					, Empleado.SaldoVacaciones
					, Empleado.EsActivo
			FROM [dbo].[Empleado] Empleado
			WHERE Empleado.Nombre LIKE @InRefName


			-- Variables de insercion a bitacora
			DECLARE @TipoDeEvento VARCHAR(32)
					, @Descripcion VARCHAR(32)
					, @VarNombre VARCHAR(32) = Empleado.Nombre
					, @VarValorDocId INT = Empleado.ValorDocumentoIdentidad
					, @VarIdPuesto INT = Empleado.IdPuesto
					, @SaldoActual MONEY = Empleado.SaldoVacaciones

			PrevEsActivo = Empleado.EsActivo -- asigna el valor anterior en caso de error
			UPDATE [dbo].[Empleado] SET EsActivo = 0
			WHERE Empleado.Nombre LIKE @InRefName
			/* WHERE Empleado.ValorDocumentoIdentidad LIKE @InRefDocumentoIdentidad */
		
		CATCH
			INSERT INTO [dbo].[DBError] VALUES 
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

			-- Si no logra borrar el empleado
			SET @TipoDeEvento = 'Intento de borrado';
			SET @Descripcion = @VarValorDocId + '' + @VarNombre + '' + @VarIdPuesto + '' + @SaldoActual


			-- En el caso que haya actualizado algun valor, devuelve a su valor original
			UPDATE [dbo].[Empleado] 
			SET EsActivo = @PrevEsActivo 
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
		END

RETURN 0
