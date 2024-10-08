using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Data;
using System.Data.SqlClient;
using Tarea_2_BD.Pages.Model;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Tarea_2_BD.Pages.View.Insert
{
    public class MovementModel : PageModel
    {

		public Empleado empleadoActual = new Empleado();
		public ConnectSQL SQL = new ConnectSQL();
		public string errorMessage = "";
		public List<TipoMovimiento> listaTipoMovimientos  = new List<TipoMovimiento>();


		public void OnGet()
        {
            ViewData["ShowLogoutButton"] = true;

            string empleado = (string)HttpContext.Session.GetString("Empleado");

			using (SQL.connection)
			{
				

				int resultCode = TraerTiposDeMovimiento(empleado); //trae los tipos de movimiento y los datos del empleado 

				if (resultCode != 0)
				{
					errorMessage = SQL.BuscarError(resultCode);
				}


			}
		}


		public int TraerTiposDeMovimiento(string empleado)
		{
			SQL.Open();
			SQL.LoadSP("[dbo].[TraerTiposDeMovimiento]");

			SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
			SQL.OutParameter("@OutValorDocumentoidentidad", SqlDbType.Int, 0);
			SQL.OutParameter("@OutSaldo", SqlDbType.Money, 0);

			SQL.InParameter("@InEmpleado", empleado, SqlDbType.VarChar);

			//ya habiendo cargado los posibles parametros entonces podemos llamar al SP
			using (SqlDataReader dr = SQL.command.ExecuteReader())
			{
				int resultCode = 0;

				if (dr.Read()) //primero verificamos si el resultcode es positivo
				{
					resultCode = dr.GetInt32(0);

					if (resultCode == 0)
					{
						Console.WriteLine("Traida de movimientos");
					}
					else
					{
						SQL.Close();
						Console.WriteLine("Error al llamar al SP");
						return resultCode;
					}

				}

				dr.NextResult(); //ya que leimos el outResultCode, leeremos los datos del dataser
				if (dr.Read()) // Verifica si hay resultados para el saldo de vacaciones
				{
					empleadoActual.SaldoVacaciones = dr.GetDecimal(0); //sacamos el saldo de vacaciones
					Console.WriteLine(empleadoActual.SaldoVacaciones);
				}


				dr.NextResult();
				if (dr.Read())
				{
					empleadoActual.ValorDocumentoIdentidad = dr.GetInt32(0);
					Console.WriteLine(empleadoActual.ValorDocumentoIdentidad);
				}


				string saldo = empleadoActual.SaldoVacaciones.ToString();
				HttpContext.Session.SetString("Saldo", saldo);
				HttpContext.Session.SetInt32("DocId", empleadoActual.ValorDocumentoIdentidad);

				dr.NextResult();

				
				

				while (dr.Read())
				{
					TipoMovimiento tipo = new TipoMovimiento();
					tipo.Nombre = dr.GetString(0);
					
					tipo.Accion = dr.GetString(1);

					string Valor = tipo.Nombre + ", " + tipo.Accion;

					Console.WriteLine(Valor);

					listaTipoMovimientos.Add(tipo);
				}
				SQL.Close();
				return resultCode;
			}

		}



		public int InsertarMovimiento(string empleado, string movimiento, decimal monto)
		{
			SQL.Open();
			SQL.LoadSP("[dbo].[InsertarMovimiento]");
			SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);

			SQL.InParameter("@InEmpleado", empleado, SqlDbType.VarChar);
			SQL.InParameter("@InMonto", monto, SqlDbType.Money);
			SQL.InParameter("@InUserName", (string)HttpContext.Session.GetString("Usuario"), SqlDbType.VarChar);
			SQL.InParameter("@InPostInIP", HttpContext.Connection.RemoteIpAddress?.ToString(), SqlDbType.VarChar);
			SQL.InParameter("@InPostTime", DateTime.Now, SqlDbType.DateTime);
			SQL.InParameter("@InNombreMovimiento", movimiento, SqlDbType.VarChar);


			SQL.ExecSP();
			int resultCode = (int)SQL.command.Parameters["@OutResultCode"].Value;
			if (resultCode != 0)
			{
				SQL.Close();
				return resultCode;
			}
			SQL.Close();
			return resultCode;

		}

		public IActionResult OnPost()
		{
            ViewData["ShowLogoutButton"] = true;
            string movimiento = Request.Form["movimientoSeleccionado"];
			string monto = Request.Form["Monto"];
			decimal montoReal;
			int resultCode;



			using (SQL.connection)
			{
				string empleado = (string)HttpContext.Session.GetString("Empleado");
				resultCode = TraerTiposDeMovimiento(empleado); //trae los tipos de movimiento y los datos del empleado 


				if (resultCode != 0)
				{
					errorMessage = SQL.BuscarError(resultCode);
					return Page();
				}

				


				// Ahora puedes usar el valor seleccionado (movimientoSeleccionado)
				if (string.IsNullOrEmpty(movimiento))
				{
					// L�gica con el valor seleccionado
					// Ejemplo: Procesar el nombre seleccionado
					errorMessage = "Tiene que seleccionar un movimiento";
					Console.WriteLine(errorMessage);
					return Page();
				}

				if (string.IsNullOrEmpty(monto))
				{
					// L�gica con el valor seleccionado
					// Ejemplo: Procesar el nombre seleccionado
					errorMessage = "El monto no puede ir vac�o";
					Console.WriteLine(errorMessage);
					return Page();
				}

				try
				{
					montoReal = Convert.ToDecimal(monto);
				}
				catch
				{
					errorMessage = "El monto debe ser un valor de Dinero";
					Console.WriteLine(errorMessage);
					return Page();
				}

				Console.WriteLine(montoReal);
				Console.WriteLine(movimiento);


				resultCode = InsertarMovimiento(empleado, movimiento, montoReal); //trae los tipos de movimiento y los datos del empleado 
				
				if (resultCode != 0)
				{
					errorMessage = SQL.BuscarError(resultCode);
					return Page();
				}

			}

			
				
			return RedirectToPage("/View/List/Movimiento");
		}


	}
}
