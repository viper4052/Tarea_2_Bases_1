/*using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.SqlServer.Server;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Reflection.PortableExecutable;
*/

using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient; // Asegúrate de usar Microsoft.Data.SqlClient
using System.Collections.Generic;

namespace Tarea2BasesDatos1.Pages.Usuarios
{
	public class Usuario
	{
		[Key]
		public int Id { get; set; }

		[DisplayName("Username")]
		[Required]
		public String Username { get; set; }

		[DisplayName("Password")]
		[Required]
		public String Password { get; set; }
	}

	public class IndexModel : PageModel
	{

		public List<Usuario> listaUsuarios = new List<Usuario>();
		SqlConnection connection = null;
		SqlCommand command = null;
		public static IConfiguration Configuration { get; set; }

		public string SuccessMessage { get; set; }

		private string getConnectionString()   // se llama al connection string que haya en el json de appsetings
		{
			var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
			Configuration = builder.Build();
			return Configuration.GetConnectionString("DefaultConnection");
		}


		public void OnGet()
		{
			SuccessMessage = TempData["SuccessMessage"] as string; // verifica si se habia hecho una inserccion


			using (connection = new SqlConnection(getConnectionString()))
			{

				connection.Open();

				command = new SqlCommand("[dbo].[ListarUsuarios]", connection);
				command.CommandType = CommandType.StoredProcedure;

				command.Parameters.Add(new SqlParameter("@OutResultCode", SqlDbType.Int));
				command.Parameters["@OutResultCode"].Value = 0;


				using (SqlDataReader dr = command.ExecuteReader())
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
						Usuario user = new Usuario();
						user.Id = dr.GetInt32(0);
						user.Username = dr.GetString(1);
						user.Password = dr.GetString(2);


						listaUsuarios.Add(user);


					}
				}

				connection.Close();
			}

		}

	}


}