USE [tarea2BD]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*

	Este procedimiento solo inserta en bitacora en el
	caso que el usuario en la interfaz grafica cancele
	el borrado del empleado.

*/


CREATE PROCEDURE [dbo].[IntentoBorrado]
	@OutResulTCode INT OUTPUT
    , @OutMensajeError VARCHAR(128)
	, @InRefName VARCHAR(128)
	, @InPostInIP VARCHAR(128)
    , @InPostTime DATETIME

AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @OutResulTCode = 0;
        SET @OutMensajeError = ' ';

		-- Variables de inserci�n a bit�cora
        DECLARE @TipoDeEvento VARCHAR(128)
                , @Descripcion VARCHAR(128)
                , @IdUser INT
                , @IdEvento INT
				, @VarNombre VARCHAR(128)
                , @VarValorDocID INT
                , @VarIdPuesto INT
                , @SaldoActual MONEY;
		
		-- Obtiene valores originales del empleado
		SELECT @VarNombre = Empleado.Nombre
               , @VarIdPuesto = Empleado.IdPuesto
               , @VarValorDocID = Empleado.ValorDocumentoIdentidad
               , @SaldoActual = Empleado.SaldoVacaciones
        FROM [dbo].[Empleado] Empleado
        WHERE Empleado.Nombre = @InRefName;
		
		-- Si se intento borrar, se inserta en bit�cora
		SET @TipoDeEvento = 'Intento de borrado';
		SET @Descripcion = CAST(@VarValorDocID AS VARCHAR) + '' + @VarNombre + '' + CAST(@VarIdPuesto AS VARCHAR) + '' + CAST(@SaldoActual AS VARCHAR);

		IF @TipoDeEvento <> ' ' BEGIN
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
			);
		END
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

		SELECT @OutMensajeError = Descripcion 
		FROM [dbo].[Error] 
		WHERE Codigo = @OutResulTCode;

		SELECT @OutMensajeError AS OutMensajeError;
	END CATCH
END
GO
