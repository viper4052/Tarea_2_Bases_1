using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace Tarea_2_BD.Pages.LogIn
{
    public class LoginModel : PageModel
    {


        public Usuario user = new Usuario();
        public void OnGet()
        {
        }

    }
    public class Usuario
    {
        [Key]
        public int Id { get; set; }

        [DisplayName("Nombre")]
        [Required]
        public String Nombre { get; set; }

        [DisplayName("Password")]
        [Required]
        public String Pass { get; set; }

    }

}
