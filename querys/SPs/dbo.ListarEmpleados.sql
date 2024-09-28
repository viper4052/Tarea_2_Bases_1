USE [tarea2BD]
GO
/****** Object:  StoredProcedure [dbo].[ListarEmpleados]    Script Date: 28/09/2024 13:05:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* Lista a todos los empleados en la BD*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 

ALTER PROCEDURE [dbo].[ListarEmpleados]
    @OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicializar el valor de retorno
        SET @OutResulTCode = 0;
		SELECT @OutResulTCode AS OutResulTCode;

        -- Seleccionar los empleados en orden alfabético
        --SELECT E.[Id] -- se esconde el Id (PK) a la hora de listar empleados


		DECLARE  @empleado TABLE  
		(                        
			Puesto VARCHAR(128) NOT NULL 
			, Nombre VARCHAR(128) NOT NULL
			, ValorDocumentoIdentidad INT NOT NULL
			, FechaContratacion DATE NOT NULL
			, SaldoVacaciones MONEY NOT NULL 
		);
		INSERT @empleado 
		(
			Puesto 
			, Nombre 
			, ValorDocumentoIdentidad 
			, FechaContratacion 
			, SaldoVacaciones 
		)
        SELECT P.Nombre 
			   , E.Nombre
			   , E.ValorDocumentoIdentidad
			   , E.FechaContratacion
			   , E.SaldoVacaciones 
        FROM dbo.Empleado E 
		INNER JOIN dbo.Puesto P ON E.IdPuesto = P.Id
		WHERE E.EsActivo <> 0
        ORDER BY E.Nombre ASC; -- muestra los empleados en orden ascendente

		SELECT Puesto
		      , Nombre
			  , ValorDocumentoIdentidad
			  , FechaContratacion
			  , SaldoVacaciones
		FROM @empleado as Empleados; 

    END TRY
    BEGIN CATCH
		-- Error de Base de Datos 
        SET @OutResulTCode = 50008;
		--SELECT @OutResulTCode AS OutResulTCode;
    END CATCH;

    SET NOCOUNT OFF;
END;
