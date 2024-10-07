using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using Tarea_2_BD.Pages.Model;

namespace Tarea_2_BD.Pages.View.UDC
{
    public class eliminarModel : PageModel
    {

        public string errorMessage = "";
        public ConnectSQL SQL = new ConnectSQL();
        public void OnGet()
        {
            ViewData["ShowLogoutButton"] = true;
        }

        public IActionResult OnPost()
        {
            ViewData["ShowLogoutButton"] = true;

            string sip = Request.Form["confirmo"];
            string nop = Request.Form["noConfirmo"];
            int resultCode;


            using (SQL.connection)
            {
                if (string.IsNullOrEmpty(sip))
                {

                    resultCode = EliminarEmpleado(int.Parse(nop));
                }
                else
                {
                    resultCode = EliminarEmpleado(int.Parse(sip));
                }

                if (resultCode != 0)
                {
                    errorMessage = SQL.BuscarError(resultCode);
                    return Page();
                }


            }
            return RedirectToPage("/View/List/Employee");
            

        }


        public int EliminarEmpleado(int EliminarEmpleado)
        {
            SQL.Open();
            SQL.LoadSP("[dbo].[EliminaEmpleado]");
            SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);

            SQL.InParameter("@InRefName", (string)HttpContext.Session.GetString("Empleado"), SqlDbType.VarChar);

            SQL.InParameter("@InUsername", (string)HttpContext.Session.GetString("Usuario"), SqlDbType.VarChar);
            SQL.InParameter("@InPostInIp", HttpContext.Connection.RemoteIpAddress?.ToString(), SqlDbType.VarChar);
            SQL.InParameter("@InPostTime", DateTime.Now, SqlDbType.DateTime);
            SQL.InParameter ("@InConfirmacion", EliminarEmpleado, SqlDbType.Int);


            

            SQL.ExecSP();
            int resultCode = (int)SQL.command.Parameters["@OutResultCode"].Value;
            Console.WriteLine(resultCode);
            SQL.Close();
            return resultCode;

        }




    }
}
