using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using Tarea_2_BD.Pages.Model;

namespace Tarea_2_BD.Pages.View.Insert
{
    public class FilteredModel : PageModel
    {
        public string errorMessage = "";
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

                SQL.LoadSP("[dbo].[FiltrarBusqueda]");

                // aca hay que hacer para que regrese a la pagina de
                // empleados sin filtrar si hay espacios en blanco o vacio
                try
                {
                    String ValorID = "8326328";//Request.Form["Filtrar"];
                    SQL.InParameter("@InNumbers", Int32.Parse(ValorID), SqlDbType.VarChar);
                    
                    SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
                    using (SqlDataReader dr1 = SQL.command.ExecuteReader())
                    {

                        if (dr1.Read()) //primero verificamos si el resultcode es positivo
                        {
                            int resultCode = dr1.GetInt32(0);

                            if (resultCode == 0)
                            {
                                Console.WriteLine("Filtrado de datos exitoso");
                            }
                            else
                            {
                                Console.WriteLine("Error al llamar al SP");
                                return;
                            }

                        }

                        dr1.NextResult(); //ya que leimos el outResultCode, leeremos los datos del dataset

                        while (dr1.Read())
                        {
                            Empleado empleado = new Empleado();
                            empleado.Nombre = dr1.GetString(0);
                            empleado.ValorDocumentoIdentidad = dr1.GetInt32(1);
                            empleado.SaldoVacaciones = dr1.GetDecimal(2);


                            listaFiltradaEmpleados.Add(empleado);


                        }
                    }
                }
                catch (Exception ex)
                {
                    String Nombre = Request.Form["Filtrar"];
                    SQL.InParameter("@InLetters", Nombre, SqlDbType.VarChar);

                    SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
                    using (SqlDataReader dr1 = SQL.command.ExecuteReader())
                    {

                        if (dr1.Read()) //primero verificamos si el resultcode es positivo
                        {
                            int resultCode = dr1.GetInt32(0);

                            if (resultCode == 0)
                            {
                                Console.WriteLine("Filtrado de datos exitoso");
                            }
                            else
                            {
                                Console.WriteLine("Error al llamar al SP");
                                return;
                            }

                        }

                        dr1.NextResult(); //ya que leimos el outResultCode, leeremos los datos del dataset

                        while (dr1.Read())
                        {
                            Empleado empleado = new Empleado();
                            empleado.Nombre = dr1.GetString(0);
                            empleado.ValorDocumentoIdentidad = dr1.GetInt32(1);
                            empleado.SaldoVacaciones = dr1.GetDecimal(2);


                            listaFiltradaEmpleados.Add(empleado);


                        }
                    }
                }


                //SQL.InParameter("@InUsername", , SqlDbType.VarChar);

                SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);


                

                SQL.Close();
            }

        }
    }
}
