--
/* Inserta error de inicio de sesion fallido 

--  Descripcion de parametros: 
-- 

--- FALTA AGREGAR # DE INTENTO

--  @outResultCode: codigo de resultado de ejecucion. 
--- 0 Se ejecuto sin errores, 
--- codigo de error mayores a 50000 son definidos manualmente por el programador. Resto son reservados
--

*/

CREATE PROCEDURE [dbo].[RegisterGeneralFailedLogin]
    @OutResulTCode INT OUTPUT
    , @IdTipoEvento INT
    , @Descripcion VARCHAR(128)
    , @IdPostByUser INT
    , @PostInIP VARCHAR(128)
    , @PostTime DATETIME
AS
BEGIN
    BEGIN TRY
        INSERT INTO BitacoraEvento
        (IdTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        
		VALUES
        (@IdTipoEvento, @Descripcion, @IdPostByUser, @PostInIP, @PostTime);

        SET @OutResulTCode = 0; -- Indica ejecucion exitosa
    END TRY
    BEGIN CATCH
        SET @OutResulTCode = 50005; -- Indica error

    END CATCH
END;


	
	--INSERT INTO BitacoraEvento(IdTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
