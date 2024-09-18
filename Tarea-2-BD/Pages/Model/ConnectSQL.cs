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
