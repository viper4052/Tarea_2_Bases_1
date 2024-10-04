using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using Tarea_2_BD.Pages.Model;

namespace Tarea_2_BD.Pages.View.List
{
    public class EditaEmpleadoModel : PageModel
    {

        public string errorMessage = "";
        public string busqueda;
        public List<Empleado> listaEmpleados = new List<Empleado>();

        public Empleado empleado = new Empleado();

        public ConnectSQL SQL = new ConnectSQL();
        public static IConfiguration Configuration { get; set; }

        public string SuccessMessage { get; set; }



        public void OnGet()
        {
            
        }

        public void OnPost()
        {
            var nuevoNombreEmpleado = Request.Form["newNombre"];
            var nuevoIdPuesto = Request.Form["newIdPuesto"];
            var nuevoValorDocumentoIdentidad = Request.Form["NewValorDocumentoIdentidad"];


            Console.WriteLine("Nuevo nombre va a ser: " + nuevoNombreEmpleado);
            Console.WriteLine("Nuevo puesto ID va a ser: " + nuevoIdPuesto);
            Console.WriteLine("Nuevo ValDocId va a ser: " + nuevoValorDocumentoIdentidad);

            using (SQL.connection)
            {
                SQL.Open();

                SQL.LoadSP("[dbo].[EditaEmpleado]");

                SQL.InParameter("@InRefName", "CRACKLOS", SqlDbType.VarChar);
                SQL.InParameter("@InNewNombre", nuevoNombreEmpleado.ToString(), SqlDbType.VarChar);
                
                SQL.ExecSP();
                SQL.Close();

            }

        }

        public int FiltraUsuarios()
        {
            SQL.Open();
            busqueda = Request.Form["Filtrar"];
            // Si el input tiene espacios vacios o esta vacio
            // del todo, devuelve la lista normal
            if (String.IsNullOrWhiteSpace(busqueda))
            {
                SQL.LoadSP("[dbo].[listarEmpleados]");
                return 0;
            }
            else
            {
                SQL.LoadSP("[dbo].[FiltrarBusqueda]");
                try
                {
                    //SQL.InParameter("@InLetters", null, SqlDbType.VarChar); // esto para que salte al filtro de numeros
                    SQL.InParameter("@InNumbers", Int32.Parse(busqueda), SqlDbType.Int);

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
