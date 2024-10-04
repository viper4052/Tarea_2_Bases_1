CREATE PROCEDURE [dbo].[EditaEmpleado]
/*
	El nombre original del Empleado va a ser la referencia principal para toda edicion
	de informacion. Por eso es la ultima variable en verificar si es NOT NULL.

	Pregunta si las demas variables no estan nulas para saber cuales editar,
	porque podria no editar las 3 al mismo tiempo.
*/

	@InRefName VARCHAR(128) /* ACA SE SUPONE VA EL NOMBRE DEL EMPLEADO ANTES DE CUALQUIER EDICION */
	, @InNewIdPuesto INT				= NULL
	, @InNewNombre VARCHAR(128)			= NULL
	, @InNewValorDocumentoIdentidad INT = NULL
	
	AS

		BEGIN

			IF @InNewIdPuesto is not null
				UPDATE [dbo].[Empleado] SET IdPuesto = @InNewIdPuesto 
				WHERE Empleado.Nombre LIKE @InRefName;


			IF @InNewValorDocumentoIdentidad is not null
				UPDATE [dbo].[Empleado] SET ValorDocumentoIdentidad = @InNewValorDocumentoIdentidad 
				WHERE Empleado.Nombre LIKE @InRefName;


			IF @InNewNombre is not null
				UPDATE [dbo].[Empleado] SET Nombre = @InNewNombre 
				WHERE Empleado.Nombre LIKE @InRefName;
		END