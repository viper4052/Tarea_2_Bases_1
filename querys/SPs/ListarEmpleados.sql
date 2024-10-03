USE [tarea2BD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* Filtra los Empleados
segun el id o letras que se pongan
si vienen los parametros vacios entonces
lista todos los activos*/

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @OutMensajeError: En caso de haber error ahi se ve desplegado
--  @InLetters: las letras a buscar
--  @InNumbers: los numeros a buscar 



ALTER PROCEDURE [dbo].[ListarEmpleados]
	@OutResulTCode INT OUTPUT
	, @OutMensajeError VARCHAR(128) OUTPUT
	, @InLetters VARCHAR(128)
	, @InNumbers INT 
	, @InUsername VARCHAR(128)
	, @InIp VARCHAR(128)
	, @InPostTime DATETIME


AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	SET @OutResulTCode = 0;
	SET @OutMensajeError = ' '; 
	SELECT @OutResulTCode AS OutResulTCode;

	--aqui se dira que tipo de listado hubo 
	DECLARE @TipoDeEvento VARCHAR(32)
			, @Descripcion VARCHAR(32);


	--Primero creamos una tabla variable donde estaran los datos listos 
	--solo poniendo lo que ocupamos, Puesto (el nombre) y ningun id 
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
		WHERE E.EsActivo <> 0;



	-- letras en los nombres
	IF @InLetters IS NOT NULL
		BEGIN
			SELECT E.Puesto
				, E.Nombre
				, E.ValorDocumentoIdentidad
				, E.FechaContratacion
				, E.SaldoVacaciones
			FROM @empleado E 
			WHERE E.Nombre LIKE '%' + @InLetters + '%'
			ORDER BY E.Nombre ASC; 

			--ahora ingresemos en bitacora
			--que realizo una busqueda por letras
			SET @TipoDeEvento = 'Consulta con filtro de nombre';
			SET @Descripcion = @InLetters;
					
		END
	ElSE
		BEGIN
	-- buscar ids relacionados 
		IF @InNumbers IS NOT NULL
			BEGIN 
				SELECT E.Puesto
				, E.Nombre
				, E.ValorDocumentoIdentidad
				, E.FechaContratacion
				, E.SaldoVacaciones
				FROM @empleado E 
				WHERE CAST(E.ValorDocumentoIdentidad AS VARCHAR(128)) LIKE  '%' + CAST(@InNumbers AS VARCHAR(128)) + '%'
				ORDER BY E.Nombre ASC; 
				

				--ahora especifiquemos si fue busqueda por numero 
				SET @TipoDeEvento = 'Consulta con filtro de cedula';
				SET @Descripcion = CONVERT(VARCHAR(32), @InNumbers);

			END
		ELSE
			BEGIN 
				SELECT E.Puesto
				, E.Nombre
				, E.ValorDocumentoIdentidad
				, E.FechaContratacion
				, E.SaldoVacaciones
				FROM @empleado E 
				ORDER BY E.Nombre ASC; 
			SET @TipoDeEvento = ' ';
			END 
		END 

	--Ahora ingresemos en bitacora lo ocurrido


	IF( @TipoDeEvento <> ' ')
	BEGIN

	INSERT INTO dbo.BitacoraEvento
			(
				IdTipoEvento
				, Descripcion
				, IdPostByUser
				, PostInIP
				, PostTime
			)
			VALUES
			(
				(SELECT Id FROM dbo.TipoEvento
				WHERE Nombre = @TipoDeEvento)
				, @Descripcion
				, (SELECT Id FROM dbo.Usuario
				WHERE Username = @InUsername) 
				, @InIp
				, @InPostTime
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
		FROM dbo.Error 
		WHERE Codigo = @OutResulTCode;

		SELECT @OutMensajeError AS OutMensajeError;  

	END CATCH 

	SET NOCOUNT OFF;
END;
