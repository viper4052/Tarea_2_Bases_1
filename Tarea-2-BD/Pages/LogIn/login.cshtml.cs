using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Tarea_2_BD.Pages.Model;
using System.Data.SqlClient;
using System.Data;
using System.Net;
using System.Runtime.InteropServices;

namespace Tarea_2_BD.Pages.LogIn
{
    public class LoginModel : PageModel
    {


        public Usuario user = new Usuario();
        public String errorMessage = "";
        public ConnectSQL SQL = new ConnectSQL();
        public bool LoginActivo = true;
        public String Ip;
        public int intentos; 
        
        
        public void OnGet()
        {
          
         
            int tiempoFuera = GetTiempoBloqueado();
            
            if(tiempoFuera < 0)
            {
                LoginActivo = true;
            }
            else
            {
                errorMessage = "Demasiados intentos de login, intente de nuevo dentro de " + tiempoFuera.ToString() + " minutos";
                LoginActivo = false;
            }
            
            
        }

        public int GetTiempoBloqueado()
        {
            SQL.Open();
            SQL.LoadSP("[dbo].[GetTiempoBloqueado]");

            SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
            SQL.OutParameter("@OutTime", SqlDbType.Int, 0);

            SQL.ExecSP();
            SQL.Close();

            try
            {
                int Time = (int)SQL.command.Parameters["@OutTime"].Value;
                return 10-Time;
            }
            catch
            {
                return -1;
            }
           
        }

        public string BuscarUsuario(String IP, DateTime date) //devuelve el tipo de error (Si hubo)
		{
			SQL.Open();
			SQL.LoadSP("[dbo].[Login]");

			SQL.InParameter("@InUsername", user.Username, SqlDbType.VarChar);
			SQL.InParameter("@InPassword", user.Pass, SqlDbType.VarChar);
			SQL.InParameter("@InPostInIP", IP, SqlDbType.VarChar);
			SQL.InParameter("@InPostTime", date, SqlDbType.DateTime);

			SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
			SQL.OutParameter("@OutIntentos", SqlDbType.Int, 0);
			SQL.OutParameter("@OutMensajeError", SqlDbType.VarChar, 128);

			SQL.ExecSP();
			SQL.Close();

            intentos = (int)SQL.command.Parameters["@OutIntentos"].Value;

            if (intentos > 3)
            {
                LoginActivo = false; 
               
            }

			return (string)SQL.command.Parameters["@OutMensajeError"].Value;
		}



		public ActionResult OnPost()
        {
            Ip = HttpContext.Connection.RemoteIpAddress?.ToString();
			
            DateTime dateNow = DateTime.Now;

			String Username = Request.Form["Nombre"];
			

			bool esSoloAlfabeticoYGuionBajo = Username.All(c => char.IsLetter(c) || c == '_' || c == ' ');

            String Password = Request.Form["Contraseña"];

            
            //verifica que los campos no esten vacios
            if (String.IsNullOrEmpty(Username) || String.IsNullOrEmpty(Password))
            {
                errorMessage = "Los espacios no pueden ir vacios";
                return Page();
            }

            //asignamos la password 
            user.Pass = Password;

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

            
            using (SQL.connection)
            {
                string posibleError = BuscarUsuario(Ip, dateNow);


                if (posibleError != " " )
                {
                    errorMessage = posibleError;

                    return Page();
				}
                else
                {                    
					return RedirectToPage("/View/List/Employee");
				}




            }
          
        }

    }

  

}
