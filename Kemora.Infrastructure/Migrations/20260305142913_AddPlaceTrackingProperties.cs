using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPlaceTrackingProperties : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LastEnrichedAt",
                table: "Places",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Source",
                table: "Places",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LastEnrichedAt",
                table: "Places");

            migrationBuilder.DropColumn(
                name: "Source",
                table: "Places");
        }
    }
}
