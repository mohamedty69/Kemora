using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPrecomputedTripPlanCache : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PrecomputedTripPlans",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CacheKey = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    ItineraryJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PlacesJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PrecomputedTripPlans", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PrecomputedTripPlans_CacheKey",
                table: "PrecomputedTripPlans",
                column: "CacheKey",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PrecomputedTripPlans");
        }
    }
}
