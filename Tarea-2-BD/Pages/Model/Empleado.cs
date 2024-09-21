using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace Tarea_2_BD.Pages.Model
{
	public class Empleado
	{
		[Key]
		public int Id { get; set; }

		[DisplayName("ValorDocumentoIdentidad")]
		[Required]
		public int ValorDocumentoIdentidad { get; set; }

		[DisplayName("Nombre")]
		[Required]
		public String Nombre { get; set; }

		[DisplayName("FechaContratacion")]
		[Required]
		public DateOnly FechaContratacion { get; set; }

		[DisplayName("SaldoVacaciones")]
		[Required]
		public decimal SaldoVacaciones { get; set; }

		[DisplayName("EsActivo")]
		[Required]
		public bool EsActivo { get; set; }


	}
}
