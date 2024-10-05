using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using System.Reflection.PortableExecutable;
using Tarea_2_BD.Pages.Model;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Tarea_2_BD.Pages.View.List
{
    public class MovimientoModel : PageModel
    {

        public Empleado empleadoActual;
		public ConnectSQL SQL = new ConnectSQL();
		public List<Movimiento> listaMovimientos;
		public string errorMessage = "";
		public void OnGet()
        {

            //Primero obtenemos el nombre del empleado 
			string empleado = (string)HttpContext.Session.GetString("Empleado");

			empleadoActual = new Empleado(); 
			empleadoActual.Nombre = empleado ;



			using (SQL.connection)
			{
				SQL.Open();

				int resultCode = ListarMovimientos(empleado);


				SQL.Close();
			}			

		}


		public int ListarMovimientos(string nombreEmpleado)
		{
			SQL.LoadSP("[dbo].[ListarMovimientos]");

			SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
			SQL.OutParameter("@OutValorDocumentoidentidad", SqlDbType.Int, 0);
			SQL.OutParameter("@OutSaldo", SqlDbType.Money, 0);
			SQL.OutParameter("@OutErrorMessage", SqlDbType.Money, 0);

			SQL.InParameter("@InEmpleado", nombreEmpleado, SqlDbType.VarChar);



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
						dr.NextResult();
						errorMessage = dr.GetString(0);
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

				


				dr.NextResult();

				listaMovimientos = new List<Movimiento>();

				while (dr.Read())
				{
					Movimiento movimiento = new Movimiento();

					movimiento.Fecha = dr.GetDateTime(0);
					movimiento.Estampa = TimeOnly.FromTimeSpan(dr.GetTimeSpan(1));
					movimiento.tipoMovimiento = dr.GetString(2);
					movimiento.Monto = dr.GetDecimal(3);
					movimiento.NuevoSaldo = dr.GetDecimal(4);
					movimiento.NombreUsuario = dr.GetString(5);
					movimiento.ipAdress = dr.GetString(6);

					listaMovimientos.Add(movimiento);
				}

				return resultCode;
			}
		}
	}
}
