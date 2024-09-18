using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using Tarea_2_BD.Pages.Model;
using System.Data.SqlClient;
using System.Data;

namespace Tarea_2_BD.Pages.LogIn
{
    public class LoginModel : PageModel
    {


        public Usuario user = new Usuario();
        public String errorMessage = "";
        public ConnectSQL SQL = new ConnectSQL();
        
        
        
        public void OnGet()
        {
        }

        public ActionResult OnPost()
        {
            String Username = Request.Form["Nombre"];

            bool esSoloAlfabeticoYGuionBajo = Username.All(c => char.IsLetter(c) || c == '_' || c == ' ');

            String Password = Request.Form["Contraseña"];


            //verifica que los campos no esten vacios
            if (String.IsNullOrEmpty(Username) || String.IsNullOrEmpty(Password))
            {
                errorMessage = "Los espacios no pueden ir vacios";
                return Page();
            }


            //verifica que el usuario no haya ingresado caracteres no validos 
            if (esSoloAlfabeticoYGuionBajo)
            {
                user.Username = Username;
            }
            else
            {
                errorMessage = "El nombre solo puede tener caracteres del alfabeto o guiones";
                return Page();
            }

            //Ahora revisemos si el usuario esta en la BD

            user.Pass = Password;

            using (SQL.connection)
            {
               
                SQL.Open();
                SQL.command = new SqlCommand("[dbo].[BuscarUsuario]", SQL.connection);     //HACER UNA FUNCION QUE SOLO HAGA FALTA PASARLE LOS PARAMETROS
                SQL.command.CommandType = CommandType.StoredProcedure;                     //Y OTRA PARA PASAR EL TIPO DE COMANDO 

                SQL.command.Parameters.Add(new SqlParameter("@InUsername", SqlDbType.VarChar));
                SQL.command.Parameters.Add(new SqlParameter("@InPassword", SqlDbType.VarChar));
                SQL.command.Parameters["@InUsername"].Value = user.Username;
                SQL.command.Parameters["@InPassword"].Value = user.Pass;

                var outResultCode = new SqlParameter("@OutResultCode", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                SQL.command.Parameters.Add(outResultCode);

                SQL.command.ExecuteNonQuery();


                int resultCode = (int)SQL.command.Parameters["@OutResultCode"].Value;

                SQL.Close();

                if (resultCode == 0)
                {
                    Console.WriteLine("HOLAAA");
                    return Page();
                }

                if (resultCode == 50001)
                {
                    Console.WriteLine("50001");
                    return Page();
                }

                if (resultCode == 50002)
                {
                    Console.WriteLine("50002");
                    return Page();
                }

                
            }    


            return Page();
        }




    }

  

}
