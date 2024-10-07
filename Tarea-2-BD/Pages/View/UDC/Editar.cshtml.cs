using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using Tarea_2_BD.Pages.Model;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Tarea_2_BD.Pages.View.UDC
{
    public class EditarModel : PageModel
    {

        public string errorMessage = "";
        public string busqueda;
        public Empleado empleado = new Empleado();
        public ConnectSQL SQL = new ConnectSQL();
        public List<string> listaPuestos = new List<string>();

        public void OnGet()
        {
            ViewData["ShowLogoutButton"] = true;
            using (SQL.connection)
            {
                traerPuestos();
            }
        }

        public IActionResult OnPost()
        {
            ViewData["ShowLogoutButton"] = true;
            using (SQL.connection)
            {
                traerPuestos();
                string nombre = (string)HttpContext.Session.GetString("Empleado");
                string user = (string)HttpContext.Session.GetString("Usuario");

                string newNombre = Request.Form["newNombre"];
                string newPuesto = Request.Form["PuestoSeleccionado"];
                string newDoc = Request.Form["NewValorDocumentoIdentidad"];


                bool nombreValido = newNombre.All(c => char.IsLetter(c) || c == '_' || c == ' ');

                int resultCode;
                int valorDodcId = 0;
            

                if (string.IsNullOrEmpty(newPuesto) && string.IsNullOrEmpty(newDoc) && string.IsNullOrEmpty(newNombre))
                {
                    // Lógica con el valor seleccionado
                    // Ejemplo: Procesar el nombre seleccionado
                    errorMessage = "Por lo menos tiene que escribir en un campo";
                    Console.WriteLine(errorMessage);
                    return Page();
                }

                if (!(string.IsNullOrEmpty(newNombre)))
                {
                    if (!nombreValido)
                    {
                        errorMessage = "El nombre solo puede tener guiones o letras";
                        return Page();
                    }
                }

                if (!(string.IsNullOrEmpty(newDoc)))
                {
                
                    try
                    {
                        valorDodcId = Convert.ToInt32(newDoc);
                    
                    }
                    catch
                    {
                        errorMessage = "El Id debe ser un valor numérico";
                        Console.WriteLine(errorMessage);
                        return Page();
                    }
                }

                // Ahora puedes usar el valor seleccionado (movimientoSeleccionado)
            
                resultCode = editarEmpleado(newNombre, newPuesto, valorDodcId);

                if (resultCode != 0)
                {
                    errorMessage = SQL.BuscarError(resultCode); 
                    return Page();
                }


            }


            return RedirectToPage("/VIew/List/Employee");
        }


        public int editarEmpleado(string newNombre, string newPuesto, int valorDodcId)
        {
            SQL.Open();
            SQL.LoadSP("[dbo].[editaEmpleado]");
            SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);

            if (newNombre == "")
            {
                SQL.InParameter("@InNewNombre", SqlDbType.VarChar);
            }
            else
            {
                SQL.InParameter("@InNewNombre", newNombre, SqlDbType.VarChar);
            }

            if (newPuesto == "")
            {
                SQL.InParameter("@InNewPuesto", SqlDbType.VarChar);
            }
            else
            {

                SQL.InParameter("@InNewPuesto", newPuesto, SqlDbType.VarChar);
            }

            if (valorDodcId == 0)
            {
                SQL.InParameter("@InNewValorDocumentoIdentidad", SqlDbType.Int);
            }
            else
            {
                SQL.InParameter("@InNewValorDocumentoIdentidad", valorDodcId, SqlDbType.Int);
            }


            SQL.InParameter("@InRefName", (string)HttpContext.Session.GetString("Empleado"), SqlDbType.VarChar);
           
            SQL.InParameter("@InUsername", (string)HttpContext.Session.GetString("Usuario"), SqlDbType.VarChar);
            SQL.InParameter("@InPostInIp", HttpContext.Connection.RemoteIpAddress?.ToString(), SqlDbType.VarChar);
            SQL.InParameter("@InPostTime",DateTime.Now , SqlDbType.DateTime);


            SQL.ExecSP();
            int resultCode = (int)SQL.command.Parameters["@OutResultCode"].Value;
            Console.WriteLine(resultCode);
            SQL.Close();
            return resultCode;
        }



        public int traerPuestos()
        {
            SQL.Open();
            SQL.LoadSP("[dbo].[TraerPuestos]");
            SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);


            int resultCode;


            using (SqlDataReader dr = SQL.command.ExecuteReader())
            {
                resultCode = 0;

                if (dr.Read()) //primero verificamos si el resultcode es positivo
                {
                    resultCode = dr.GetInt32(0);

                    if (resultCode == 0)
                    {
                        Console.WriteLine("Traida de movimientos");
                    }
                    else
                    {
                        Console.WriteLine("Error al llamar al SP");
                        SQL.Close();
                        return resultCode;
                    }

                }

                dr.NextResult(); //ya que leimos el outResultCode, leeremos los datos del dataseT

                while (dr.Read())
                {
                    string puesto;
                    puesto = dr.GetString(0);

                    Console.WriteLine(puesto);

                    listaPuestos.Add(puesto);
                }
            }
            SQL.Close();
            return resultCode;

        }



    }
}
