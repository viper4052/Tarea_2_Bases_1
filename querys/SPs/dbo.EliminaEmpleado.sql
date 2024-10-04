CREATE PROCEDURE [dbo].[EliminaEmpleado]
	/*
		Elimina de forma logica, solo asigna el valor de la columna
		EsActivo a 0, y no elimina de la base de datos.

		No se cual es mas comodo, si con valor de documento de identidad
		o con el nombre unico de empleado
	*/
	@InRefName VARCHAR(128)
	, @InRefDocumentoIdentidad int
AS
	BEGIN
		UPDATE [dbo].[Empleado] SET EsActivo = 0
		WHERE Empleado.Nombre LIKE @InRefName
		/* WHERE Empleado.ValorDocumentoIdentidad LIKE @InRefDocumentoIdentidad */
	END

RETURN 0
