using Microsoft.EntityFrameworkCore;
using OMUS.Data;

public static class DbInitializer
{
    public static void Initialize(IServiceProvider serviceProvider)
    {
        using var context = new OMUSContext(
            serviceProvider.GetRequiredService<DbContextOptions<OMUSContext>>());

        context.Database.EnsureCreated();
        SeedCategories(context);
        SeedVialActors(context);
    }

    private static void SeedCategories(OMUSContext context)
    {
        if (context.Categories.Any())
        {
            return; // DB has been seeded
        }


        var categories = new Category[]
        {
            new Category { Id = 1, ParentId = null, CategoryName = "Inseguridad vial", hasVictim = true, hasDateTime = true },
            new Category { Id = 4, ParentId = null, CategoryName = "Inseguridad personal", hasVictim = true, hasDateTime = true },
            new Category { Id = 7, ParentId = null, CategoryName = "Mala condición de infraestructura", hasVictim = false, hasDateTime = true },
            new Category { Id = 10, ParentId = null, CategoryName = "Mala condición de red y su operación", hasVictim = false, hasDateTime = true },
            new Category { Id = 13, ParentId = null, CategoryName = "Otro actor maltrata o acosa", hasVictim = true, hasDateTime = true },
            new Category { Id = 14, ParentId = null, CategoryName = "Otro actor infringe alguna norma", hasVictim = true, hasDateTime = true },
            new Category { Id = 15, ParentId = null, CategoryName = "Buen comportamiento de algún actor", hasVictim = false, hasDateTime = true },
            new Category { Id = 38, ParentId = null, CategoryName = "Propuestas ciudadanas", hasVictim = false, hasDateTime = false },
            new Category { Id = 48, ParentId = null, CategoryName = "Felicitar al sector de movilidad", hasVictim = false, hasDateTime = false },
            new Category { Id = 2, ParentId = 1, CategoryName = "Near-miss", hasVictim = true, hasDateTime = true },
            new Category { Id = 3, ParentId = 1, CategoryName = "Atropello", hasVictim = true, hasDateTime = true },
            new Category { Id = 16, ParentId = 4, CategoryName = "Hurto de automotores", hasVictim = false, hasDateTime = true },
            new Category { Id = 17, ParentId = 4, CategoryName = "Hurto de motocicletas", hasVictim = false, hasDateTime = true },
            new Category { Id = 18, ParentId = 4, CategoryName = "Hurto de bicicletas o patinetas", hasVictim = false, hasDateTime = true },
            new Category { Id = 19, ParentId = 4, CategoryName = "Delitos en transporte público (incluye TransMilenio, tranvía Cuenca)", hasVictim = false, hasDateTime = true },
            new Category { Id = 8, ParentId = 7, CategoryName = "Hueco o daño en infraestructura", hasVictim = false, hasDateTime = true },
            new Category { Id = 9, ParentId = 7, CategoryName = "Falta de conectividad en red", hasVictim = false, hasDateTime = true },
            new Category { Id = 27, ParentId = 7, CategoryName = "Falta de señalización", hasVictim = false, hasDateTime = true },
            new Category { Id = 28, ParentId = 7, CategoryName = "Acera angosta o inexistente", hasVictim = false, hasDateTime = true },
            new Category { Id = 29, ParentId = 7, CategoryName = "Obstáculo peligroso", hasVictim = false, hasDateTime = true },
            new Category { Id = 30, ParentId = 7, CategoryName = "Falta de iluminación", hasVictim = false, hasDateTime = true },
            new Category { Id = 11, ParentId = 7, CategoryName = "Semáforo dañado", hasVictim = false, hasDateTime = true },
            new Category { Id = 12, ParentId = 10, CategoryName = "Bus que no pasa", hasVictim = false, hasDateTime = true },
            new Category { Id = 31, ParentId = 10, CategoryName = "Semáforo con tiempo de verde muy corto", hasVictim = false, hasDateTime = true },
            new Category { Id = 32, ParentId = 10, CategoryName = "Daño en la estación de bus o transmilenio (o tranvía en Cuenca)", hasVictim = false, hasDateTime = true },
            new Category { Id = 33, ParentId = 10, CategoryName = "Bus dañado", hasVictim = false, hasDateTime = true },
            new Category { Id = 50, ParentId = 10, CategoryName = "Información de rutas inexistente o robada", hasVictim = false, hasDateTime = true },
            new Category { Id = 51, ParentId = 10, CategoryName = "Cambio o incumplimiento de ruta", hasVictim = false, hasDateTime = true },
            new Category { Id = 34, ParentId = 10, CategoryName = "No hay estación de bus o transmilenio o tranvía (Cuenca) en un rango menor a 10 minutos caminando", hasVictim = false, hasDateTime = true },
            new Category { Id = 52, ParentId = 13, CategoryName = "Acoso sexual en transporte público", hasVictim = true, hasDateTime = true },
            new Category { Id = 20, ParentId = 14, CategoryName = "(c) por lugares y en horarios que estén permitidos", hasVictim = false, hasDateTime = true },
            new Category { Id = 21, ParentId = 14, CategoryName = "(d) sin exceder los límites de velocidad permitidos", hasVictim = false, hasDateTime = true },
            new Category { Id = 22, ParentId = 14, CategoryName = "(e) respetando la luz roja del semáforo", hasVictim = false, hasDateTime = true },
            new Category { Id = 23, ParentId = 14, CategoryName = "Pisa la cebra", hasVictim = false, hasDateTime = true },
            new Category { Id = 35, ParentId = 14, CategoryName = "Motocicleta invade cicloinfraestructura", hasVictim = false, hasDateTime = true },
            new Category { Id = 36, ParentId = 14, CategoryName = "Mal parqueado", hasVictim = false, hasDateTime = true },
            new Category { Id = 24, ParentId = 15, CategoryName = "Ceder la vía a peatón", hasVictim = false, hasDateTime = false },
            new Category { Id = 25, ParentId = 15, CategoryName = "Ayudar a alguien", hasVictim = false, hasDateTime = false },
            new Category { Id = 37, ParentId = 15, CategoryName = "Conducción segura de un conductor de bus o taxi", hasVictim = false, hasDateTime = false },
            new Category { Id = 39, ParentId = 38, CategoryName = "Pedir una parada del sistema de Transporte Público", hasVictim = false, hasDateTime = false },
            new Category { Id = 40, ParentId = 38, CategoryName = "Pedir una estación de bicicleta compartida", hasVictim = false, hasDateTime = false },
            new Category { Id = 41, ParentId = 38, CategoryName = "Pedir una estación de mecánica", hasVictim = false, hasDateTime = false },
            new Category { Id = 42, ParentId = 38, CategoryName = "Pedir un cicloparqueadero", hasVictim = false, hasDateTime = false },
            new Category { Id = 43, ParentId = 38, CategoryName = "Pedir una pacificación de tráfico o un cruce seguro en el barrio", hasVictim = false, hasDateTime = false },
            new Category { Id = 46, ParentId = 38, CategoryName = "Pedir infraestructura para personas con discapacidad en un lugar específico", hasVictim = false, hasDateTime = false },
            new Category { Id = 47, ParentId = 38, CategoryName = "Pedir una zona de parqueo en vía", hasVictim = false, hasDateTime = false },
            new Category { Id = 53, ParentId = 48, CategoryName = "Pusieron ciclovía", hasVictim = false, hasDateTime = false },
            new Category { Id = 54, ParentId = 48, CategoryName = "Arreglaron / instalaron acera", hasVictim = false, hasDateTime = false },
            new Category { Id = 56, ParentId = 13, CategoryName = "Trato irrespetuoso a los usuarios de transporte público", hasVictim = false, hasDateTime = true },
            new Category { Id = 57, ParentId = 13, CategoryName = "Violencia física en transporte público", hasVictim = false, hasDateTime = true },
            new Category { Id = 58, ParentId = 1, CategoryName = "Choque con sólo daños", hasVictim = false, hasDateTime = true },
            new Category { Id = 59, ParentId = 1, CategoryName = "Conducción peligrosa de un taxi", hasVictim = true, hasDateTime = true },
            new Category { Id = 60, ParentId = 4, CategoryName = "Otro (Inseguridad personal)", hasVictim = false, hasDateTime = true },
            new Category { Id = 61, ParentId = 7, CategoryName = "Otro (Mala condición de infraestructura)", hasVictim = false, hasDateTime = true },
            new Category { Id = 62, ParentId = 10, CategoryName = "Patineta o bici compartida mal parqueada/bloqueando acera, o no en estación.", hasVictim = false, hasDateTime = true },
            new Category { Id = 63, ParentId = 13, CategoryName = "Otro (Otro actor maltrata o acosa)", hasVictim = false, hasDateTime = true },
            new Category { Id = 64, ParentId = 14, CategoryName = "Otro (Otro actor infringe alguna norma)", hasVictim = false, hasDateTime = true },
            new Category { Id = 65, ParentId = 15, CategoryName = "Otro (Buen comportamiento de algún actor)", hasVictim = false, hasDateTime = false },
            new Category { Id = 66, ParentId = 38, CategoryName = "Otro (Propuestas ciudadanas)", hasVictim = false, hasDateTime = false },
            new Category { Id = 67, ParentId = 48, CategoryName = "Otro (Felicitar al sector de movilidad)", hasVictim = false, hasDateTime = false },
            new Category { Id = 68, ParentId = 1, CategoryName = "Otro (Inseguridad vial)", hasVictim = false, hasDateTime = true },
            new Category { Id = 69, ParentId = 10, CategoryName = "Otro (Mala condición de red y su operación)", hasVictim = false, hasDateTime = true }
        };

        foreach (var category in categories)
        {
            context.Categories.Add(category);
        }

        context.SaveChanges();
    }
    private static void SeedVialActors(OMUSContext context)
    {
        if (context.VialActors.Any())
        {
            return; // DB has been seeded
        }

        var vialActors = new VialActor[]
        {
            new VialActor { Id = 1, Name = "Peatón" },
            new VialActor { Id = 2, Name = "Pasajero" },
            new VialActor { Id = 3, Name = "Conductor automóvil" },
            new VialActor { Id = 4, Name = "Conductor taxi" },
            new VialActor { Id = 5, Name = "Conductor vehículo de transporte público" },
            new VialActor { Id = 6, Name = "Conductor motociclista" },
            new VialActor { Id = 7, Name = "Conductor Patineta" },
            new VialActor { Id = 8, Name = "Conductor Ciclomotor" },
            new VialActor { Id = 9, Name = "Conductor Taxi-ciclomotor" },
            new VialActor { Id = 10, Name = "Conductor Carga pesada" },
            new VialActor { Id = 11, Name = "Ciclista" },
            new VialActor { Id = 12, Name = "Nadie (solo daños)" }
        };


        foreach (var actor in vialActors)
        {
            context.VialActors.Add(actor);
        }

        context.SaveChanges();
    }

}
