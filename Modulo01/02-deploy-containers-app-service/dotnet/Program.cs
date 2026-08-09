var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () =>
{
    var environment = Environment.GetEnvironmentVariable("ENVIRONMENT") ?? "unknown";
    var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "NO CONFIGURADO";
    var secretPreview = dbPassword.Length >= 3 ? dbPassword[..3] : dbPassword;
    return $"Corriendo en: {environment} | Secreto (primeros 3 chars): {secretPreview}*** v2";
});

app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

var port = Environment.GetEnvironmentVariable("PORT") ?? "8000";
app.Run($"http://0.0.0.0:{port}");
