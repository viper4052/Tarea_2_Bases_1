var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
	app.UseExceptionHandler("/Error");
}
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();


app.MapGet("/", () => Results.Redirect("/Usuarios/Index"));  // la pagina predeterminada sea la del grid

app.MapRazorPages();

app.Run();