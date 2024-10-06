
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

CREATE PROCEDURE [dbo].[TraerPuestos]
	@OutResultCode INT OUTPUT 

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		

		SET @OutResultCode = 0; 
		SELECT @OutResultCode as OutResultCode;
	

		SELECT P.Nombre
		FROM dbo.Puesto P ;

		
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
