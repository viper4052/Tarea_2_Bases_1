using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using System.Data.SqlTypes;

namespace Tarea_2_BD.Pages.Model
{
	public class Empleado
	{
		
        [DisplayName("Puesto")]
        [Required]
        public String Puesto { get; set; }

        [DisplayName("ValorDocumentoIdentidad")]
		[Required]
		public int ValorDocumentoIdentidad { get; set; }

		[DisplayName("Nombre")]
		[Required]
		public String Nombre { get; set; }

		[DisplayName("FechaContratacion")]
		[Required]
		public DateTime FechaContratacion { get; set; }

		[DisplayName("SaldoVacaciones")]
		[Required]
		public decimal SaldoVacaciones { get; set; }


	}
}
