using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OMUS.Migrations
{
    /// <inheritdoc />
    public partial class AddHasInvolvedActor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "hasInvolvedActor",
                table: "Categories",
                type: "tinyint(1)",
                nullable: false,
                defaultValue: false);

            migrationBuilder.Sql(@"
        UPDATE Categories SET hasInvolvedActor = TRUE WHERE Id IN (
            1, 2, 3, 20, 21, 22, 23, 25, 35, 36, 52, 58, 59, 68, 82, 83, 84, 85, 86, 87
        );");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "hasInvolvedActor",
                table: "Categories");
        }
    }
}
