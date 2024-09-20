CREATE PROCEDURE [dbo].[ListarEmpleados]
    @OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicializar el valor de retorno
        SET @OutResulTCode = 0;
		SELECT @OutResulTCode AS OutResulTCode;  -- Este codigo se agrega solo si hay problemas para obtener este  valor como parametros


        -- Seleccionar los empleados en orden alfabético
        --SELECT E.[Id] -- se esconde el Id (PK) a la hora de listar empleados
          Select E.[Nombre]
            , E.[ValorDocumentoIdentidad]
			, E.[SaldoVacaciones]
        FROM dbo.Empleado E 
        ORDER BY E.Nombre ASC; -- muestra los empleados en orden ascendente

    END TRY
    BEGIN CATCH
         -- Establecer un código de error estándar
        SET @OutResulTCode = 50005;
    END CATCH;

    SET NOCOUNT OFF;
END;
GO