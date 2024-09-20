USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Lista a todos los empleados en la BD*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 

CREATE PROCEDURE [dbo].[ListarEmpleados]
    @OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicializar el valor de retorno
        SET @OutResulTCode = 0;


        -- Seleccionar los empleados en orden alfabético
        --SELECT E.[Id] -- se esconde el Id (PK) a la hora de listar empleados
          Select E.[Nombre]
            , E.[ValorDocumentoIdentidad]
			, E.[SaldoVacaciones]
        FROM dbo.Empleado E 
        ORDER BY E.Nombre ASC; -- muestra los empleados en orden ascendente

    END TRY
    BEGIN CATCH
		-- Error de Base de Datos 
        SET @OutResulTCode = 50008;
    END CATCH;

    SET NOCOUNT OFF;
END;
GO


