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

--  Dado un codigo de error devuelve la descripicion del mismo 
  
--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @OutMensajeError: aqui se dejara el mensaje de error (en caso de haberlo)
--  @InRefName: nombre de referencia original de empleado
--  @InNewIdPuesto: aqui el posible nuevo ID de puesto de empleado
--  @InNewNombre: aqui el posible nuevo NOMBRE de empleado
--  @InNewValorDocumentoIdentidad: aqui el posible nuevo valor de documento de identidad del empleado
--  @InPost: aqui el IP de donde se realizo la solicitud 
--  @InPostTime: aqui el momento en el que se hizo la consulta 
*/

ALTER PROCEDURE [dbo].[EditaEmpleado]
    @OutResulTCode INT OUTPUT,
    @OutMensajeError VARCHAR(128),
    @InRefName VARCHAR(128),
    @InNewIdPuesto INT = NULL,
    @InNewNombre VARCHAR(128) = NULL,
    @InNewValorDocumentoIdentidad INT = NULL,
    @InUsername VARCHAR(128),
    @InPassword VARCHAR(128),
    @InPostInIP VARCHAR(128),
    @InPostTime DATETIME 
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @OutResulTCode = 0;
        SET @OutMensajeError = ' ';

        -- Variables de inserción a bitácora
        DECLARE @TipoDeEvento VARCHAR(128),
                @Descripcion VARCHAR(128),
                @IdUser INT,
                @IdEvento INT,
                @PrevNombre VARCHAR(32),
                @PrevValorDocID INT,
                @PrevIdPuesto INT,
                @SaldoActual MONEY;

        -- Obtener valores originales
        SELECT @PrevNombre = Empleado.Nombre,
               @PrevIdPuesto = Empleado.IdPuesto,
               @PrevValorDocID = Empleado.ValorDocumentoIdentidad,
               @SaldoActual = Empleado.SaldoVacaciones
        FROM [dbo].[Empleado] Empleado
        WHERE Empleado.Nombre = @InRefName;

        -- Actualizar datos si no son nulos
        IF @InNewIdPuesto IS NOT NULL
            UPDATE [dbo].[Empleado] SET IdPuesto = @InNewIdPuesto WHERE Nombre = @InRefName;

        IF @InNewValorDocumentoIdentidad IS NOT NULL
            UPDATE [dbo].[Empleado] SET ValorDocumentoIdentidad = @InNewValorDocumentoIdentidad WHERE Nombre = @InRefName;

        IF @InNewNombre IS NOT NULL
            UPDATE [dbo].[Empleado] SET Nombre = @InNewNombre WHERE Nombre = @InRefName;

        -- Si el update fue exitoso, se inserta en bitácora
        SET @TipoDeEvento = 'Update exitoso';
        SET @Descripcion = @PrevValorDocID + '' + @PrevNombre + '' + CAST(@PrevIdPuesto AS VARCHAR) + '|'
                          + CAST(@InNewValorDocumentoIdentidad AS VARCHAR) + '' + @InNewNombre + '' + CAST(@InNewIdPuesto AS VARCHAR) + '' + CAST(@SaldoActual AS VARCHAR);

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

        -- Si no logra actualizar el empleado
        SET @TipoDeEvento = 'Update no exitoso';
        SET @Descripcion = @PrevValorDocID + '' + @PrevNombre + '' + CAST(@PrevIdPuesto AS VARCHAR) + '|'
                          + CAST(@InNewValorDocumentoIdentidad AS VARCHAR) + '' + @InNewNombre + '' + CAST(@InNewIdPuesto AS VARCHAR) + '' + CAST(@SaldoActual AS VARCHAR);

        -- Revertir cambios
        UPDATE [dbo].[Empleado] 
        SET Nombre = @PrevNombre, 
            IdPuesto = @PrevIdPuesto, 
            ValorDocumentoIdentidad = @PrevValorDocID
        WHERE Nombre = @InRefName;

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
    END CATCH;

    RETURN;
END;
