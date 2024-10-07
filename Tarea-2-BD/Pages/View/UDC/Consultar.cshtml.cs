using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using Tarea_2_BD.Pages.Model;

namespace Tarea_2_BD.Pages.View.UDC
{
    public class ConsultarModel : PageModel
    {


		public string errorMessage = "";
		public string busqueda;
		public Empleado empleado = new Empleado();
		public ConnectSQL SQL = new ConnectSQL();

		public void OnGet()
        {
			ViewData["ShowLogoutButton"] = true;
			using (SQL.connection)
			{
				int resultCode = ConsultarEmpleado();

				if (resultCode != 0)
				{
					SQL.BuscarError(resultCode);
				}
			}

        }


		public int ConsultarEmpleado()
		{
			SQL.Open();
			SQL.LoadSP("[dbo].[ConsultarEmpleado]");
			SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
			SQL.OutParameter("@OutSaldo", SqlDbType.Money, 0);
			SQL.OutParameter ("@OutDocId", SqlDbType.Int, 0);
			SQL.OutParameter("@OutPuesto", SqlDbType.VarChar, 16);

			SQL.InParameter("@InName", (string)HttpContext.Session.GetString("Empleado"), SqlDbType.VarChar);
			SQL.InParameter("@InUsername", (string)HttpContext.Session.GetString("Empleado"), SqlDbType.VarChar);
			SQL.InParameter("@InPostInIp", HttpContext.Connection.RemoteIpAddress?.ToString(), SqlDbType.VarChar);
			SQL.InParameter("@InPostTime", DateTime.Now, SqlDbType.DateTime);


			SQL.ExecSP();
			int resultCode = (int)SQL.command.Parameters["@OutResultCode"].Value;

			empleado.ValorDocumentoIdentidad = (int)SQL.command.Parameters["@OutDocId"].Value;
			empleado.Puesto = (string)SQL.command.Parameters["@OutPuesto"].Value;
			empleado.SaldoVacaciones = (decimal)SQL.command.Parameters["@OutSaldo"].Value;
			empleado.Nombre = (string)HttpContext.Session.GetString("Empleado");


			Console.WriteLine(resultCode);
			SQL.Close();
			return resultCode;
		}
    }
}
