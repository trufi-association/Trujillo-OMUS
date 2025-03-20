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
            new Category { Id = 1, ParentId = null, CategoryName = "Inseguridad vial", hasVictim = true, hasDateTime = true, hasInvolvedActor = true },
            new Category { Id = 4, ParentId = null, CategoryName = "Inseguridad personal", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 7, ParentId = null, CategoryName = "Huecos, algo malo en las pistas, veredas u otra afectación a la infraestructura.", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 10, ParentId = null, CategoryName = "Algo anda mal con las pistas, veredas, ciclovías, etc.", hasVictim = false, hasDateTime = true, hasInvolvedActor = true },
            new Category { Id = 13, ParentId = null, CategoryName = "Otro actor maltrata o acosa", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 14, ParentId = null, CategoryName = "Quiero reportar una infracción que cometió un conductor, peatón o ciclista", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 15, ParentId = null, CategoryName = "Buen comportamiento de algún actor", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 38, ParentId = null, CategoryName = "Propuestas ciudadanas", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 48, ParentId = null, CategoryName = "Felicitar al sector de movilidad", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 2, ParentId = 1, CategoryName = "Near-miss", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 3, ParentId = 1, CategoryName = "Atropello", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 16, ParentId = 4, CategoryName = "Robaron un carro", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 17, ParentId = 4, CategoryName = "Hurto de motocicletas", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 18, ParentId = 4, CategoryName = "Hurto de bicicletas o patinetas", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 19, ParentId = 4, CategoryName = "Delitos en transporte público (incluye TransMilenio, tranvía Cuenca)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 8, ParentId = 7, CategoryName = "Hueco o daño en infraestructura", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 9, ParentId = 7, CategoryName = "Hay una calle/vereda o ciclovía que no conecta con nada", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 27, ParentId = 7, CategoryName = "Falta de señalización", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 28, ParentId = 7, CategoryName = "No hay vereda o espacio suficiente para caminar", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 29, ParentId = 7, CategoryName = "Hay un obstáculo en la pista", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 30, ParentId = 7, CategoryName = "Falta de iluminación", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 11, ParentId = 7, CategoryName = "Semáforo dañado", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 12, ParentId = 10, CategoryName = "El bus/combi no pasa a tiempo", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 31, ParentId = 10, CategoryName = "Semáforo con tiempo de verde muy corto", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 32, ParentId = 10, CategoryName = "Daño en el paradero de bus micros o combis", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 33, ParentId = 10, CategoryName = "Hay un bus/combi en malas condiciones o dañado", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 50, ParentId = 10, CategoryName = "Información de rutas inexistente o robada", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 51, ParentId = 10, CategoryName = "La ruta del bus/combi se desvió o no realizó el recorrido acostumbrado", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 34, ParentId = 10, CategoryName = "Tuve que caminar más de 10 minutos para encontrar un paradero", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 52, ParentId = 13, CategoryName = "Acoso sexual en transporte público", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 20, ParentId = 14, CategoryName = "(c) por lugares y en horarios que estén permitidos", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 21, ParentId = 14, CategoryName = "Alguien no respetó el semáforo en rojo", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 22, ParentId = 14, CategoryName = "(e) respetando la luz roja del semáforo)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 23, ParentId = 14, CategoryName = "Un vehículo pisó el cruce peatonal", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 35, ParentId = 14, CategoryName = "Motocicleta invade cicloinfraestructura", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 36, ParentId = 14, CategoryName = "Un vehículo está obstruyendo el paso o está estacionado en una zona prohibida", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 24, ParentId = 15, CategoryName = "Ceder la vía a peatón", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 25, ParentId = 15, CategoryName = "Ayudar a alguien", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 37, ParentId = 15, CategoryName = "Conducción segura de un conductor de bus o taxi", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 39, ParentId = 38, CategoryName = "Pedir una parada del sistema de Transporte Público", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 40, ParentId = 38, CategoryName = "Quiero que haya un paradero de bicicletas compartidas", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 41, ParentId = 38, CategoryName = "Pedir una estación de mecánica", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 42, ParentId = 38, CategoryName = "Quiero que instalen un estacionamiento para bicicletas", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 43, ParentId = 38, CategoryName = "Pedir una pacificación de tráfico o un cruce seguro en el barrio", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 46, ParentId = 38, CategoryName = "Pedir infraestructura para personas con discapacidad en un lugar específico", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 47, ParentId = 38, CategoryName = "Quiero que pongan un estacionamiento pagado en pista", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 53, ParentId = 48, CategoryName = "Pusieron ciclovía", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 54, ParentId = 48, CategoryName = "Arreglaron / instalaron vereda", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},    new Category { Id = 56, ParentId = 13, CategoryName = "Me maltrataron verbalmente (o a alguien más) en el transporte público", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 57, ParentId = 13, CategoryName = "Violencia física en transporte público", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 58, ParentId = 1, CategoryName = "Choque con sólo daños", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 59, ParentId = 1, CategoryName = "Conducción peligrosa de un taxi", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 60, ParentId = 4, CategoryName = "Otro (Inseguridad personal)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 61, ParentId = 7, CategoryName = "Otro (Mala condición de infraestructura)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 62, ParentId = 10, CategoryName = "Patineta o bici compartida mal parqueada/bloqueando vereda, o no en paradero", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 63, ParentId = 13, CategoryName = "Otro (Otro actor maltrata o acosa)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 64, ParentId = 14, CategoryName = "Otro (Otro actor infringe alguna norma)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 65, ParentId = 15, CategoryName = "Otro (Buen comportamiento de algún actor)", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 66, ParentId = 38, CategoryName = "Otro (Propuestas ciudadanas)", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 67, ParentId = 48, CategoryName = "Otro (Felicitar al sector de movilidad)", hasVictim = false, hasDateTime = false , hasInvolvedActor = true},
            new Category { Id = 68, ParentId = 1, CategoryName = "Otro (Inseguridad vial)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 69, ParentId = 10, CategoryName = "Otro (Mala condición de red y su operación)", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 70, ParentId = 57, CategoryName = "Me agredieron por mi expresión de género u orientación sexual", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 71, ParentId = null, CategoryName = "Me siento insegura(o) en este lugar", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 72, ParentId = 7, CategoryName = "No hay rampas adecuadas para circular en silla de ruedas", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 73, ParentId = 7, CategoryName = "Falta señalización táctil o de piso para personas con discapacidad visual", hasVictim = false, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 74, ParentId = 13, CategoryName = "No me recogieron por ser estudiante", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 75, ParentId = 13, CategoryName = "No me recogieron por tener una discapacidad", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
            new Category { Id = 76, ParentId = 13, CategoryName = "No me recogieron por ser adulto mayor", hasVictim = true, hasDateTime = true , hasInvolvedActor = true},
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
