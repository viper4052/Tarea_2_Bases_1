using Microsoft.AspNetCore.Cors.Infrastructure;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics.Eventing.Reader;
using Tarea_2_BD.Pages.Model;
using static System.Runtime.InteropServices.JavaScript.JSType;


namespace Tarea_2_BD.Pages.View.List
{
    public class EmployeeModel : PageModel
    {
        public string errorMessage = "";
        public List<Empleado> listaEmpleados = new List<Empleado>();
        public ConnectSQL SQL = new ConnectSQL();
		public string Ip;
		public int whatFilter; // 0 = no hubo, 1=letras, 2=numeros 

		public string SuccessMessage { get; set; }



        public void OnGet(string username)
        {
						
			using (SQL.connection)
            {

                SQL.Open();

                SQL.LoadSP("[dbo].[ListarEmpleados]");

                SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);


                using (SqlDataReader dr = SQL.command.ExecuteReader())
                {

                    if (dr.Read()) //primero verificamos si el resultcode es positivo
                    {
                        int resultCode = dr.GetInt32(0);

                        if (resultCode == 0)
                        {
                            Console.WriteLine("Traida de datos exitosa");
                        }
                        else
                        {
                            Console.WriteLine("Error al llamar al SP");
                            errorMessage = SQL.BuscarError(resultCode);
                            return;
                        }

                    }

                    dr.NextResult(); //ya que leimos el outResultCode, leeremos los datos del dataser

                    while (dr.Read())
                    {
                        Empleado empleado = new Empleado();
                        empleado.Puesto = dr.GetString(0);
                        empleado.Nombre = dr.GetString(1);
                        empleado.ValorDocumentoIdentidad = dr.GetInt32(2);
                        empleado.FechaContratacion = dr.GetDateTime(3);
                        empleado.SaldoVacaciones = (decimal)dr.GetSqlMoney(4);

                        listaEmpleados.Add(empleado);


                    }
                }

                SQL.Close();
            }

        }

		


		//aqui estaran todos los metodos post 

		public IActionResult OnPostEditarEmpleado()
		{
			
			string busqueda = Request.Form["Nombre"];
			HttpContext.Session.SetString("Empleado", busqueda);
			Console.WriteLine(busqueda);
			Console.WriteLine("editar");

			return Page();
		}
		public IActionResult OnPostBorrarEmpleado()
		{
			string busqueda = Request.Form["Nombre"];
			HttpContext.Session.SetString("Empleado", busqueda);
			Console.WriteLine(busqueda);
			Console.WriteLine("borrar");
			return Page();
		}
		public IActionResult OnPostConsultarEmpleado()
		{
			string busqueda = Request.Form["Nombre"];
			HttpContext.Session.SetString("Empleado", busqueda);
			Console.WriteLine(busqueda);
			Console.WriteLine("empleado");
			return Page();
		}
		public IActionResult OnPostConsultarMovimientos()
		{
			string busqueda = Request.Form["Nombre"];
			HttpContext.Session.SetString("Empleado", busqueda);
			Console.WriteLine(busqueda);
			Console.WriteLine("movimientos");
			return Page();
		}



		public void OnPostFiltrarEmpleados()
        {
			Ip = HttpContext.Connection.RemoteIpAddress?.ToString();
			string busqueda = Request.Form["Filtrar"];


            Console.WriteLine(busqueda);

			using (SQL.connection)
			{
				SQL.Open();
				SQL.LoadSP("[dbo].[FiltrarBusqueda]");

				SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);

				if (string.IsNullOrWhiteSpace(busqueda))
				{
					SQL.InParameter("@InLetters", SqlDbType.VarChar); //se mandan los parametros nulos 
					SQL.InParameter("@InNumbers", SqlDbType.Int);
					whatFilter = 0;
				}
				else
				{
					try //aqui verificamos si tratamos de buscar por valor doc id 
					{
						int number = int.Parse(busqueda);
						SQL.InParameter("@InLetters", SqlDbType.VarChar); //se mandan los parametros nulos 
						SQL.InParameter("@InNumbers", number, SqlDbType.Int);
						whatFilter = 1;

					}
					catch //estamos buscando por nombre 
					{
						SQL.InParameter("@InLetters", busqueda, SqlDbType.VarChar); //se mandan los parametros nulos 
						SQL.InParameter("@InNumbers", SqlDbType.Int);
						whatFilter = 2;
					}

				}

				//ya habiendo cargado los posibles parametros entonces podemos llamar al SP
				using (SqlDataReader dr = SQL.command.ExecuteReader())
				{

					if (dr.Read()) //primero verificamos si el resultcode es positivo
					{
						int resultCode = dr.GetInt32(0);

						if (resultCode == 0)
						{
							Console.WriteLine("Traida de datos exitosa");
						}
						else
						{
							errorMessage = SQL.BuscarError(resultCode);
							Console.WriteLine("Error al llamar al SP");
							return;
						}

					}

					dr.NextResult(); //ya que leimos el outResultCode, leeremos los datos del dataser
					listaEmpleados = new List<Empleado>();
					while (dr.Read())
					{
						Empleado empleado = new Empleado();
						empleado.Puesto = dr.GetString(0);
						empleado.Nombre = dr.GetString(1);
						empleado.ValorDocumentoIdentidad = dr.GetInt32(2);
						empleado.FechaContratacion = dr.GetDateTime(3);
						empleado.SaldoVacaciones = (decimal)dr.GetSqlMoney(4);

						listaEmpleados.Add(empleado);
					}
				}
				SQL.Close();

				//ahora hay que buscar que toca ingresar en bitacora

				string username = SQL.UltimoUsuario();
				if (whatFilter == 1)
				{
					SQL.IngresarBitacora("Consulta con filtro de cedula", busqueda, username, Ip, DateTime.Now);
				}
				else if (whatFilter == 2)
				{
					SQL.IngresarBitacora("Consulta con filtro de nombre", busqueda, username, Ip, DateTime.Now);
				}




			}


		}
	}
}