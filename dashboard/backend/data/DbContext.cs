using Microsoft.EntityFrameworkCore;

namespace OMUS.Data
{
    public class OMUSContext : DbContext
    {
        public OMUSContext(DbContextOptions<OMUSContext> options) : base(options) { }

        public DbSet<Category> Categories { get; set; }
        public DbSet<VialActor> VialActors { get; set; }
        public DbSet<Report> Reports { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

        }
    }
}
