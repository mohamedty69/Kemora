using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddStoriesAndPostLocation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "LocationId",
                table: "Posts",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Stories",
                columns: table => new
                {
                    StoryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MediaUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MediaType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UserID = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    LocationId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stories", x => x.StoryID);
                    table.ForeignKey(
                        name: "FK_Stories_AspNetUsers_UserID",
                        column: x => x.UserID,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Stories_Places_LocationId",
                        column: x => x.LocationId,
                        principalTable: "Places",
                        principalColumn: "PlaceID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Posts_LocationId",
                table: "Posts",
                column: "LocationId");

            migrationBuilder.CreateIndex(
                name: "IX_Stories_LocationId",
                table: "Stories",
                column: "LocationId");

            migrationBuilder.CreateIndex(
                name: "IX_Stories_UserID",
                table: "Stories",
                column: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK_Posts_Places_LocationId",
                table: "Posts",
                column: "LocationId",
                principalTable: "Places",
                principalColumn: "PlaceID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Posts_Places_LocationId",
                table: "Posts");

            migrationBuilder.DropTable(
                name: "Stories");

            migrationBuilder.DropIndex(
                name: "IX_Posts_LocationId",
                table: "Posts");

            migrationBuilder.DropColumn(
                name: "LocationId",
                table: "Posts");
        }
    }
}
