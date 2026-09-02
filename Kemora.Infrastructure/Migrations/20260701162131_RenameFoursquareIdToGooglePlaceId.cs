using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    /// <summary>
    /// Renames the Places.FoursquareId column to GooglePlaceId to reflect the
    /// actual data provider: the only IPlacesDataService implementation is now
    /// GooglePlacesService (Google Places API v1). The Foursquare integration
    /// was removed on 2026-06-30; the column name is being corrected to match.
    /// </summary>
    public partial class RenameFoursquareIdToGooglePlaceId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "FoursquareId",
                table: "Places",
                newName: "GooglePlaceId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "GooglePlaceId",
                table: "Places",
                newName: "FoursquareId");
        }
    }
}
