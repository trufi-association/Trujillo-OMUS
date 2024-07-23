using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using OMUS.Data;
using System;
using System.Linq;

public static class DbInitializer
{
    public static void Initialize(IServiceProvider serviceProvider)
    {
        using var context = new OMUSContext(
            serviceProvider.GetRequiredService<DbContextOptions<OMUSContext>>());

        context.Database.EnsureCreated();

    }
}
