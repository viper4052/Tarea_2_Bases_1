USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Filtra los Empleados
segun el id o letras que se pongan */

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @@InLetters: las letras a buscar
--  @@InNumbers: los numeros a buscar 



ALTER PROCEDURE [dbo].[FiltrarBusqueda]
	@OutResulTCode INT OUTPUT
	, @InLetters VARCHAR(128) 
	, @InNumbers INT 

AS
BEGIN
	SET NOCOUNT ON;
	SET @OutResulTCode = 0;

	-- letras en los nombres
	IF @InLetters IS NOT NULL
		BEGIN
			SELECT Nombre
				   , ValorDocumentoIdentidad
			       , SaldoVacaciones 
			FROM dbo.Empleado
			WHERE Empleado.Nombre LIKE '%' + @InLetters + '%'
		END
	ElSE
		BEGIN
	-- buscar ids relacionados 
		IF @InNumbers IS NOT NULL
			BEGIN 
				SELECT Nombre
				       , ValorDocumentoIdentidad
			           , SaldoVacaciones 
				FROM dbo.Empleado
				WHERE CAST(Empleado.ValorDocumentoIdentidad AS VARCHAR(128)) LIKE  '%' + CAST(@InNumbers AS VARCHAR(128)) + '%';
				
			END
		ELSE
			BEGIN 
				SET @OutResulTCode = 50008;
				EXEC ListarEmpleados @OutResulTCode = 0;
			END
		END 

	SET NOCOUNT OFF;
	

	SET @OutResulTCode = 0;
END;