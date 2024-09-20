CREATE PROCEDURE [dbo].[FiltrarBusqueda]
	@OutResulTCode INT OUTPUT
	, @InLetters VARCHAR(128) = null
	, @InNumbers INT = null

AS
BEGIN
	SET NOCOUNT ON;
	SET @OutResulTCode = 0;

	-- Busca usuario por USERNAME
	IF @InLetters IS NOT NULL
	(
		SELECT Nombre FROM dbo.Empleado
		WHERE Empleado.Nombre LIKE '%' + @InLetters + '%'
	)
	BEGIN 
		SET @OutResulTCode = 50007;
		EXEC ListarEmpleados @OutresulTcode =0;
	END 

	IF @InNumbers IS NOT NULL
	(
		SELECT ValorDocumentoIdentidad FROM dbo.Empleado
		WHERE Empleado.ValorDocumentoIdentidad LIKE '%' + @InNumbers + '%'
	)
	BEGIN 
		SET @OutResulTCode = 50009;
		EXEC ListarEmpleados @OutresulTcode =0;
	END

	SET NOCOUNT OFF;
	

	SET @OutResulTCode = 0;
END;