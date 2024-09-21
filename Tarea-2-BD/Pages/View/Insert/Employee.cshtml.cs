using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using Tarea_2_BD.Pages.Model;


namespace Tarea_2_BD.Pages.View.Insert
{
    public class EmployeeModel : PageModel
    {
        public string errorMessage = "";
		public List<Empleado> listaEmpleados = new List<Empleado>();
		public List<Empleado> listaFiltradaEmpleados = new List<Empleado>();

		public Empleado empleado = new Empleado();

		public ConnectSQL SQL = new ConnectSQL();
		public static IConfiguration Configuration { get; set; }

		public string SuccessMessage { get; set; }

		

		public void OnGet()
		{
			SuccessMessage = TempData["SuccessMessage"] as string; //esto verifica si se habia hecho una inserccion


			using (SQL.connection)
			{

				SQL.Open();

				SQL.LoadSP("[dbo].[ListarEmpleados]");

				SQL.OutParameter("@OutResultCode", SqlDbType.Int,0);


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
							return;
						}

					}

					dr.NextResult(); //ya que leimos el outResultCode, leeremos los datos del dataser

					while (dr.Read())
					{
						Empleado empleado = new Empleado();
						empleado.Nombre = dr.GetString(0);
						empleado.ValorDocumentoIdentidad = dr.GetInt32(1);
						empleado.SaldoVacaciones = dr.GetDecimal(2);


						listaEmpleados.Add(empleado);


					}
				}

				SQL.Close();
			}

		}

		public int FiltraUsuarios()
		{
			SQL.Open();
			String busqueda = Request.Form["Filtrar"];
			// Si el input tiene espacios vacios o esta vacio
			// del todo, devuelve la lista normal
			if (String.IsNullOrWhiteSpace(busqueda)) {
				SQL.LoadSP("[dbo].[listarEmpleados]");
				return 0;
			}
			else
			{
                SQL.LoadSP("[dbo].[FiltrarBusqueda]");
                try
                {
                    //SQL.InParameter("@InLetters", null, SqlDbType.VarChar); // esto para que salte al filtro de numeros
                    SQL.InParameter("@InNumbers", busqueda, SqlDbType.Int);

                }
                catch (Exception ex)
                {
					SQL.InParameter("@InLetters", busqueda, SqlDbType.VarChar);
                    //SQL.InParameter("@InNumbers", null, SqlDbType.Int); // esto para que salte al filtro de letras

                }
            }

			SQL.ExecSP();
			SQL.Close();

            return (int)SQL.command.Parameters["@OutResultCode"].Value;
        }
	}
}
