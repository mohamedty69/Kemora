using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RemoveGoogleAndWikipediaAndAddFoursquareAndOpenRouter : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "GooglePlaceID",
                table: "Places",
                newName: "FoursquareId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "FoursquareId",
                table: "Places",
                newName: "GooglePlaceID");
        }
    }
}
