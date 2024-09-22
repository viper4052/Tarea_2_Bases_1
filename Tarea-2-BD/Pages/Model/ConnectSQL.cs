﻿using System.Data;
using System.Data.SqlClient;

namespace Tarea_2_BD.Pages.Model
{
    public class ConnectSQL
    {
        public static IConfiguration Configuration { get; set; }
        public SqlConnection connection = null;
        public SqlCommand command = null;
        


        public ConnectSQL()
        {
            connection = new SqlConnection(getConnectionString());
        }

        private string getConnectionString()   //este metodo llama al connection string que haya en el json de appsetings
        {
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            Configuration = builder.Build();
            return Configuration.GetConnectionString("DefaultConnection");
        }

        public void LoadSP(String pCommand)//Esto guarda en command que vamos a trabajar con SPS
        {
            command = new SqlCommand(pCommand, connection);//pCommand se refiere al nombre del SP
            command.CommandType = CommandType.StoredProcedure;//Esto lo asigna como SP 
        }

        public void ExecSP ()
        {
            command.ExecuteNonQuery();//Esto ejecuta SPs
        }

        public void InParameter<V>(String pName, V pValue, SqlDbType type)  //Este le pone los parametros de entrada a los SPs
        {
            command.Parameters.Add(new SqlParameter(pName, type)); //le pone el tipo y el nombre en la BD 
            command.Parameters[pName].Value = pValue;  //esto le asigna el valor 
        }
        public void OutParameter(String pName, SqlDbType type, int lenght) //Este le pone los parametros de salida a los SPs
        {
            if (type == SqlDbType.VarChar)
            {
                command.Parameters.Add(new SqlParameter(pName, type, lenght));//le pone el tipo y el nombre en la BD 
            }
            else
            {
                command.Parameters.Add(new SqlParameter(pName, type));//le pone el tipo y el nombre en la BD 
            }
            command.Parameters[pName].Direction = ParameterDirection.Output; //este le dice que la direccion es de output 
        }


        
       
        

                                                            /*-------------------------
         
                                                              A PARTIR DE AQUI VAN A 
                                                            SEGUIR LOS SP QUE SE USARAN
                                                                   EN EL PROGRAMA

                                                             --------------------------*/
       
        
        public int IngresarBitacora
            (
            String TipoEvento
            , String Descripcion
            , String Username
            , String PostInIP
            , DateTime Date
            )
        {
            Open();

            //cargamos el SP
            LoadSP("[dbo].[IngresarBitacora]");

            //Cargamos Parametros 
            InParameter("@InTipoDeEvento",TipoEvento, SqlDbType.VarChar);
            InParameter("@InDescripcion", Descripcion, SqlDbType.VarChar);
            InParameter("@InUsername", Username,SqlDbType.VarChar);
            InParameter("@InPostInIP", PostInIP,SqlDbType.VarChar);
            InParameter("@InPostTime", Date, SqlDbType.DateTime);

            OutParameter("@OutResultCode", SqlDbType.Int, 0);

            //lo ejecutamos 
            ExecSP();

            Close();

            return (int)command.Parameters["@OutResultCode"].Value; 
        }



        public String BuscarError(int resultCode)//retorna mensajes de error de acuerdo al codigo
        {                                        // resuelve requirimiento 8, de mensajes de error 
            Open();
            //cargamos SP
            LoadSP("[dbo].[BuscaTipoDeError]"); 

            //Cargamos Parametros 
            InParameter("@InCodigo", resultCode, SqlDbType.Int);
            OutParameter("@OutResultCode", SqlDbType.Int, 0);
            OutParameter("@OutDescripcion", SqlDbType.VarChar, 128);

            //lo ejecutamos 
            ExecSP();

            Close();

            return (String)command.Parameters["@OutDescripcion"].Value;
        }


        public void Open()
        {
            connection.Open();
        }

        public void Close()
        {
            connection.Close();
        }
        
       


    }
}
