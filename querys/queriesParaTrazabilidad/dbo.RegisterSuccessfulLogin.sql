--
/* Inserta log de inicio de sesion exitoso

--  Descripcion de parametros: 
-- ninguno


--  @outResultCode: codigo de resultado de ejecucion. 
--- 0 Se ejecuto sin errores, 
--- codigo de error mayores a 50000 son definidos manualmente por el programador. Resto son reservados
--

*/

CREATE PROCEDURE [dbo].[SuccessfulLogin]
    @OutResulTCode INT OUTPUT
    , @IdPostByUser INT
    , @PostInIP VARCHAR(128)
    , @PostTime DATETIME
AS
BEGIN
    BEGIN TRY
        INSERT INTO BitacoraEvento
        (IdPostByUser, PostInIP, PostTime)
        
		VALUES
        ( @IdPostByUser, @PostInIP, @PostTime);

        SET @OutResulTCode = 0; -- Indica ejecucion exitosa
    END TRY
    BEGIN CATCH
        SET @OutResulTCode = 50006; -- Indica error

    END CATCH
END;