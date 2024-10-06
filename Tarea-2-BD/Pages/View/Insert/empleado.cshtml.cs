using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Routing.Constraints;
using System.Data;
using System.Data.SqlClient;
using Tarea_2_BD.Pages.Model;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Tarea_2_BD.Pages.View.Insert
{
    public class empleadoModel : PageModel
    {
        public Empleado empleado = new Empleado();
        public ConnectSQL SQL = new ConnectSQL();
        public string errorMessage = "";
        public List<string> listaPuestos = new List<string>();
        
        
        public void OnGet()
        {
            using (SQL.connection)
            {
                SQL.Open();

                traerPuestos();

                SQL.Close();    
            }
        }


        public int traerPuestos()
        {
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
                        dr.NextResult();
                        errorMessage = dr.GetString(0);
                        Console.WriteLine("Error al llamar al SP");
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

               return resultCode;

        }

        public int InsertarEmpleado(string Nombre, string PuestoSeleccionado, string ValorDocId)
        {
            SQL.LoadSP("[dbo].[InsertarEmpleado]");
            SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
            SQL.OutParameter("@OutErrorMessage", SqlDbType.VarChar, 128);

            SQL.InParameter("@InPuesto", PuestoSeleccionado, SqlDbType.VarChar);
            SQL.InParameter("@InNombre", Nombre, SqlDbType.VarChar);
            SQL.InParameter("@InUser", (string)HttpContext.Session.GetString("Usuario"), SqlDbType.VarChar);
            SQL.InParameter("@InPostInIp", HttpContext.Connection.RemoteIpAddress?.ToString(), SqlDbType.VarChar);
            SQL.InParameter("@InDocID", ValorDocId, SqlDbType.Int);


            SQL.ExecSP();
            int resultCode = (int)SQL.command.Parameters["@OutResultCode"].Value;
            if (resultCode != 0)
            {
                errorMessage = (string)SQL.command.Parameters["@OutErrorMessage"].Value;
                return resultCode;
            }
            return resultCode;
        }

        public IActionResult OnPost()
        {
            string ValorDocId = Request.Form["ValorDocId"];
            string Nombre = Request.Form["Nombre"];
            string PuestoSeleccionado = Request.Form["PuestoSeleccionado"];
            int resultCode;
            bool esSoloAlfabeticoYGuionBajo = Nombre.All(c => char.IsLetter(c) || c == '_' || c == ' ');

            //primero las validaciones


            if (string.IsNullOrEmpty(Nombre) || string.IsNullOrEmpty(ValorDocId) || string.IsNullOrEmpty(PuestoSeleccionado))
            {
                errorMessage = "Los espacios no pueden ir vacios";
                return Page();
            }


            //verifica que el usuario no haya ingresado caracteres no validos 
            if (esSoloAlfabeticoYGuionBajo)
            {
                empleado.Nombre = Nombre;
            }
            else
            {
                errorMessage = "El nombre solo puede tener caracteres del alfabeto o guiones";
                return Page();
            }

            //verifica que el usairo si haya ingresado el salario en formato correcto
            try
            {
                int Salar = int.Parse(ValorDocId);
                empleado.ValorDocumentoIdentidad = Salar;
            }
            catch
            {
                errorMessage = "El documento de identidad debe ser numerico";
                return Page();
            }






            using (SQL.connection)
            {
                SQL.Open();

                traerPuestos();

                resultCode = InsertarEmpleado(Nombre, PuestoSeleccionado, ValorDocId);

                SQL.Close();
            }

            if (resultCode != 0)
            {
                return Page();
            }

            return RedirectToPage("/View/List/Employee");


        }
    }
}
