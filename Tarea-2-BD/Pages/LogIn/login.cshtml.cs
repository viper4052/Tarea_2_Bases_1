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
        
        
        
        public void OnGet()
        {
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
            
            return (int)SQL.command.Parameters["@OutResultCode"].Value; ;
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
                String Ip = HttpContext.Connection.RemoteIpAddress?.ToString();

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
                    String Descripcion = resultCode.ToString();


                    errorMessage = SQL.BuscarError(resultCode);

                    resultCode = SQL.IngresarBitacora("Login No Exitoso", "", user.Username, Ip); //este comando inserta en bitacora el fracaso
                    
                    return Page();
                    

                }
                       
            }
          
        }

    }

  

}
