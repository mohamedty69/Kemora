using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddTripPlaceIsVisited : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsVisited",
                table: "TripPlaces",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsVisited",
                table: "TripPlaces");
        }
    }
}
