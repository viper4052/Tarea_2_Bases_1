USE [tarea2BD]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* Dados datos para crear un movimiento si intentara
annadir a la tabla de movimientos y restar el saldo 
correspondiente al usuario, solo que */

--  Descripcion de parametros: 

--  @outResultCode: codigo de resultado de ejecucion. 0 Corrio sin errores, 
--  @outIntentos: da el numero de intentos 
--  @InTipoEvento: da el tipo de evento para así buscar su id
--  @InUsername: da el nombre del usuario con el buscaremos cual su Id

CREATE PROCEDURE [dbo].[InsertarMovimiento]
	@OutResultCode INT OUTPUT
	, @InIdEmpleado
	, @InMonto
	, @InNuevoSaldo
	, @InIdPostByUser
	, @InPostInIP
	, @InPostTime
	, @InIdTipoMovimiento
AS
BEGIN
	SET NOCOUNT ON;