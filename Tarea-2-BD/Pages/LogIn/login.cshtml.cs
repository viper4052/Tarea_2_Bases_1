using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Tarea_2_BD.Pages.Model;
using System.Data.SqlClient;
using System.Data;
using System.Net;

namespace Tarea_2_BD.Pages.LogIn
{
    public class LoginModel : PageModel
    {


        public Usuario user = new Usuario();
        public String errorMessage = "";
        public ConnectSQL SQL = new ConnectSQL();
        public bool LoginActivo = true;
        public String Ip;
        
        
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
        public int BuscarUsuario()
        {
            SQL.Open();
            SQL.LoadSP("[dbo].[BuscarUsuario]");

            SQL.InParameter("@InUsername", user.Username, SqlDbType.VarChar);
            SQL.InParameter("@InPassword", user.Pass, SqlDbType.VarChar);

            SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);

            SQL.ExecSP();
            SQL.Close();
            
            return (int)SQL.command.Parameters["@OutResultCode"].Value; 
        }

        public int GetIntentos(String pTipoEvento, String pUserName)
        {
            SQL.Open();
            SQL.LoadSP("[dbo].[GetIntentos]");

            SQL.InParameter("@InUsername", pUserName, SqlDbType.VarChar);
            SQL.InParameter("@InTipoEvento", pTipoEvento, SqlDbType.VarChar);

            SQL.OutParameter("@OutResultCode", SqlDbType.Int, 0);
            SQL.OutParameter("@OutIntentos", SqlDbType.Int, 0);

            SQL.ExecSP();

            int codeResult = (int)SQL.command.Parameters["@OutResultCode"].Value;
            int tries = (int)SQL.command.Parameters["@OutIntentos"].Value;

            SQL.Close();


           
            if (codeResult != 0)
            {
                errorMessage = SQL.BuscarError(codeResult);

                if (codeResult == 50003)
                {
                    LoginActivo = false;
                    SQL.IngresarBitacora("Login deshabilitado", "", user.Username, Ip);
                }
            }
            
 
            return tries;

        }

        
        public ActionResult OnPost()
        {
            Ip = HttpContext.Connection.RemoteIpAddress?.ToString();

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

                
                int resultCode = BuscarUsuario();
               

                if (resultCode == 0) //login exitoso
                {
                    
                    
                    resultCode = SQL.IngresarBitacora("Login Exitoso","",user.Username,Ip); //este comando inserta en bitacora el evento exitoso

                    

                    if (resultCode != 0)
                    {
                        errorMessage = SQL.BuscarError(resultCode);
                        return Page();
                    }
                    return RedirectToPage("/View/Insert/Employee");
                }

                else
                {    
                    


                    errorMessage = SQL.BuscarError(resultCode);

                    int intentos = GetIntentos("Login No Exitoso", user.Username);

                    String descripcion = intentos.ToString() + "," + resultCode.ToString();


                    resultCode = SQL.IngresarBitacora("Login No Exitoso", descripcion, user.Username, Ip); //este comando inserta en bitacora el fracaso
                    
                    return Page();
                    

                }
                       
            }
          
        }

    }

  

}
