USE tarea2BD
--Indices y Secondary keys:	


-- Secondary keys de Usuario 
CREATE NONCLUSTERED INDEX Idx_Usuario_Username 
ON dbo.Usuario 
(
	Username ASC   --Indice ascendente 
)
GO

CREATE NONCLUSTERED INDEX Idx_Usuario_Pass 
ON dbo.Usuario 
(
	Pass ASC   --Indice ascendente 
)
GO


-- Secondary keys de empleado
CREATE NONCLUSTERED INDEX Idx_Empleado_Nombre 
ON dbo.Empleado  
(
	Nombre ASC   --Indice ascendente 
)
GO

CREATE NONCLUSTERED INDEX Idx_Empleado_ValDocId
ON dbo.Empleado  
(
	ValorDocumentoIdentidad ASC   --Indice ascendente 
)
GO

CREATE NONCLUSTERED INDEX Idx_BitacoraEvento_PostTime 
ON dbo.BitacoraEvento 
(
	PostTime DESC
);
GO