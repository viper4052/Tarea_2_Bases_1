
USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dado el nombre del empleado busca algunos de sus datos correspondientes
y los entrega, junto a la lista de todos sus movimientos*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InEmpleado: De el se toma que empleado es 
--  @OutValorDocumentoidentidad: da el valor del Documento de identidad
--  @OutSaldo : da el saldo actual del empleado
--  @OutErrorMessage : da el mensaje de error en caso de haber ocurrido un error 

CREATE PROCEDURE [dbo].[TraerTiposDeMovimiento]
	@OutResultCode INT OUTPUT 
	, @OutValorDocumentoidentidad INT OUTPUT
	, @OutSaldo MONEY OUTPUT
	, @OutErrorMessage VARCHAR(128) OUTPUT
	, @InEmpleado VARCHAR(128)

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @IdEmpleado INT; 

		SET @OutResultCode = 0; 
		SELECT @OutResultCode as OutResultCode;
		--Primero saquemos los datos del empleado

		SELECT @OutValorDocumentoidentidad = E.ValorDocumentoIdentidad 
		       , @OutSaldo = E.SaldoVacaciones
			   , @IdEmpleado = E.Id
		FROM dbo.Empleado E
		WHERE E.Nombre = @InEmpleado; 

		SELECT @OutSaldo AS SaldoActual;
		SELECT @OutValorDocumentoidentidad AS ValorDocumentoidentidad;
		--ahora listemos los movimientos

		SELECT TM.Nombre, TM.TipoDeAccion
		FROM dbo.TipoMovimiento TM;		
		
	END TRY
	BEGIN CATCH
		-- si no se logra insertar se denomina como error de la BD

		SET @OutResultCode = 50008;

		SELECT Er.Descripcion as Descripcion
		FROM dbo.Error Er
		WHERE Er.Codigo = @OutResultCode;

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
