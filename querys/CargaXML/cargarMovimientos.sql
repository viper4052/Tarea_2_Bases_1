USE [tarea2BD];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET NOCOUNT ON;
GO
	BEGIN TRY
	
	--primero vamos a cargar el XML en una tabla variable

	DECLARE  @XmlTable TABLE
	(
		XmlCol XML
	);

	--Metemos el  XML a la tabla variable 
	INSERT INTO @XmlTable(XmlCol)
	SELECT BulkColumn
	FROM OPENROWSET
	(
		BULK 'C:\prueba\datos.xml'
		, SINGLE_BLOB
	)
	AS x;


	--Declaramos una tabla variable para manejar los datos de movimiento 
	DECLARE  @movimientos TABLE -- a este si es mejor hacerle una tabla variable para 
	(                           -- luego hacer el InnerJoin con todos los 3 Fks
		Id INT PRIMARY KEY  IDENTITY(1,1) NOT NULL
		, ValorDocId INT NOT NULL 
		, IdTipoMovimiento VARCHAR(128) NOT NULL
		, Monto INT NOT NULL
		, PostByUser VARCHAR(128) NOT NULL
		, PostInIP VARCHAR(128) NOT NULL
		, PostTime DATETIME NOT NULL
	);

	INSERT INTO @movimientos
	(
		ValorDocId
		, IdTipoMovimiento 
		, Monto 
		, PostByUser
		, PostInIP 
		, PostTime 
	)
	Select result.ValorDocId
		   , result.IdTipoMovimiento 
		   , result.Monto 
		   , result.PostByUser
		   , result.PostInIP 
		   , result.PostTime  
	FROM @XmlTable
	CROSS APPLY 
	(
		SELECT
			ValorDocId = z.value('@ValorDocId','INT')
			, IdTipoMovimiento = z.value('@IdTipoMovimiento', 'VARCHAR(128)')
			, Monto = z.value('@Monto','MONEY')
			, PostByUser = z.value('@PostByUser', 'VARCHAR(128)') 
			, PostInIP = z.value('@PostInIP','VARCHAR(128)')
			, PostTime = z.value('@PostTime','DATETIME')
		FROM XmlCol.nodes('Datos/Movimientos/movimiento') T(z)
	) result;


	/*ya en esta tabla variable estan los datos parciales para movimiento ahora
	toca manipularlos para poder ser ingresados a empleado
	
	Tambien toca controlar programaticamente que efectivamente los n movimiento,
	fueron cargados (para poder implementar eso visto en clase vamos a asumir
	se va a verificar cuantas inserciones hubo en el dia, y si hubo menos de las
	que se tenia prevista se controla el error)
	*/
	DECLARE @Date DATETIME --Se usa para validaciones
			, @LastId INT --dice cual fue el ultimo ID en ser cargado
			, @lo INT --es el indice bajo para el while
			, @hi INT --es el índice que dice cuanto es el máximo que se puede procesar
			, @IdEmpleado INT --Para insertar en M
			, @Nombre VARCHAR(128) --Para Updatear en E
			, @IdTipoMovimiento INT --Para insertar en M
			, @Monto MONEY --Para insertar en M
			, @NuevoSaldo MONEY--Para insertar en M y E
			, @UserId INT --Para insertar en BE
			, @Descripcion VARCHAR(128) --Para insertar en BE
			, @IdUSer INT --Para insertar en BE y M
			, @IdEvento INT --para insertar en BE
			, @Ip  VARCHAR(128) --Para insertar en BE y M
			, @PostTime DATETIME --Para insertar en BE y M
			, @ResultCode INT
			, @valorDocId INT --sirve para alistar la descripcion
			, @NombreMovimiento VARCHAR(32)--sirve para alistar la descripcion
			


	SELECT @hi = MAX(Id)
	FROM @movimientos; --seleccionamos el tamaño de @empleado

	SELECT @IdEvento = TE.id FROM dbo.TipoEvento TE --dejamos lista la Id de Inserta Empleado
	WHERE TE.Nombre ='Insertar movimiento exitoso';
	
	SET @ResultCode = 0;
	
	SET @Date = GETDATE();  --la fecha del movimiento
	
	
	

	IF EXISTS (SELECT BE.Id from dbo.BitacoraEvento BE 
				WHERE CAST(PostTime as DATE) = CAST(@Date as DATE) 
				and BE.IdTipoEvento =@IdEvento)
	BEGIN 
		SELECT TOP 1 @lo = M.Id 
		FROM dbo.Movimiento M 
		ORDER BY M.Id DESC;

		SET @lo += 1
		
		
		
	END
	ELSE  -- si no se ha hecho la carga se pone @lo en 1
	BEGIN
		SET @lo = 1;
	END;
	
	WHILE (@lo <= @hi)
	BEGIN 
		
		--selecionamos los datos que ocupamos de @empleado y dbo.puesto 
		SELECT @IdEmpleado = E.Id
			   , @IdTipoMovimiento = TM.Id
			   , @NombreMovimiento = M.IdTipoMovimiento
			   , @Monto = M.Monto
			   , @PostTime = M.PostTime
			   , @IdUSer = U.Id
			   , @Ip = M.PostInIP
			   , @valorDocId = M.ValorDocId --nos servirá para hacer la descripcion
			   , @Nombre = E.Nombre --nos servirá para hacer la descripcion

		FROM @movimientos M
		INNER JOIN dbo.Empleado E on M.ValorDocId = E.ValorDocumentoIdentidad 
		INNER JOIN dbo.TipoMovimiento TM on M.IdTipoMovimiento = TM.Nombre
		INNER JOIN dbo.Usuario U on M.PostByUser = U.Username
		WHERE M.id = @lo;

		--Seleccionamos el saldo actual
		SELECT @NuevoSaldo = E.SaldoVacaciones 
		FROM dbo.Empleado E
		WHERE @Nombre = E.Nombre;

			
		--Vemos si es negativo o no 
		

		IF((SELECT TM.TipoDeAccion 
		   FROM dbo.TipoMovimiento TM
		   WHERE TM.id = @IdTipoMovimiento) = 'Debito')
		BEGIN
			SET @NuevoSaldo -= @Monto;
		END
		ELSE
		BEGIN 
			SET @NuevoSaldo += @Monto
		END;
		

		IF(@NuevoSaldo < 0)
		BEGIN
			SET @ResultCode = 50011;
			SELECT @IdEvento = TE.Id 
			FROM dbo.TipoEvento TE
			WHERE TE.Nombre = 'Intento de insertar movimiento';
			THROW @ResultCode, 'Monto del movimiento rechazado pues si se aplicar el saldo seria negativo.', 0;
		END;


		--alistamos la descripcion en caso de haber insertado bien 
		SET @Descripcion = CONVERT(VARCHAR(8), @valorDocId)
						   + ',' + @Nombre
						   + ',' + CONVERT(VARCHAR(16),@NuevoSaldo)
						   + ',' + @NombreMovimiento
						   + ',' + CONVERT(VARCHAR(16),@Monto);


		BEGIN TRANSACTION
		--Insertamos en empleado 
		INSERT INTO dbo.Movimiento
		(
			IdEmpleado
			, IdTipoMovimiento
			, Monto
			, NuevoSaldo
			, IdPostByUser
			, PostInIP
			, PostTime
		)
		VALUES 
		(
			@IdEmpleado
			, @IdTipoMovimiento
			, @Monto
			, @NuevoSaldo
			, @IdUSer
			, @Ip
			, @PostTime
		)

		
		--Insertamos en BitacoraEvento 
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
			@IdEvento
			, @Descripcion
			, @IdUSer
			, @Ip	
			, @Date
		)


		--le hacemos el update al empleado 
		UPDATE dbo.Empleado
		SET SaldoVacaciones = @NuevoSaldo
		WHERE Nombre = @Nombre

		COMMIT TRANSACTION

		SET @lo += 1;
	END;

	SELECT @ResultCode as Result; 

	END TRY
	BEGIN CATCH

	SELECT @ResultCode as Result; 

	IF @@TRANCOUNT > 0 
	BEGIN 
	ROLLBACK; 
	END; 

	SELECT TOP 1 @LastId = E.Id --vamos a ver cual fue el ultimo en ser procesado 
	FROM dbo.Empleado E 
	ORDER BY Id DESC;
	 
	 
	IF(@lo <> @LastId or @ResultCode <> 0) --si esto se activa 
	BEGIN                        --significa que fue que no se pudo insertar
		 
		 SET @Descripcion = (SELECT Er.Descripcion 
							FROM dbo.Error Er--seleccionamos cual tipo de error fue 
							WHERE codigo = @ResultCode) 
							+ ',' +CONVERT(VARCHAR(8), @valorDocId)
						    + ',' + @Nombre
						    + ',' + CONVERT(VARCHAR(16),@NuevoSaldo)
						    + ',' + @NombreMovimiento
						    + ',' + CONVERT(VARCHAR(16),@Monto);
		
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
			@IdEvento
			, @Descripcion
			, @IdUSer
			, @Ip	
			, @Date
		)

	END;


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
	END CATCH;


SET NOCOUNT OFF;
GO


