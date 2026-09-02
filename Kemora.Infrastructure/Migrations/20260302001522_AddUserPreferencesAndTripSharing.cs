using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddUserPreferencesAndTripSharing : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "LinkedTripId",
                table: "Posts",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ImageURL",
                table: "Governorates",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "UserPreferencesJSON",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Posts_LinkedTripId",
                table: "Posts",
                column: "LinkedTripId");

            migrationBuilder.AddForeignKey(
                name: "FK_Posts_Trips_LinkedTripId",
                table: "Posts",
                column: "LinkedTripId",
                principalTable: "Trips",
                principalColumn: "TripID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Posts_Trips_LinkedTripId",
                table: "Posts");

            migrationBuilder.DropIndex(
                name: "IX_Posts_LinkedTripId",
                table: "Posts");

            migrationBuilder.DropColumn(
                name: "LinkedTripId",
                table: "Posts");

            migrationBuilder.DropColumn(
                name: "ImageURL",
                table: "Governorates");

            migrationBuilder.DropColumn(
                name: "UserPreferencesJSON",
                table: "AspNetUsers");
        }
    }
}
