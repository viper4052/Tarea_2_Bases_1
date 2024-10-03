USE [tarea2BD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* Filtra los Empleados
segun el id o letras que se pongan */

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @InLetters: las letras a buscar
--  @InNumbers: los numeros a buscar 



ALTER PROCEDURE [dbo].[FiltrarBusqueda]
	@OutResulTCode INT OUTPUT
	, @InLetters VARCHAR(128)
	, @InNumbers INT 

AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	SET @OutResulTCode = 0;
	SELECT @OutResulTCode AS OutResulTCode;

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
			END
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
	END CATCH 

	SET NOCOUNT OFF;
END;
