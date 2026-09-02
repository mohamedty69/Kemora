using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Kemora.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AllowNullablePlaceFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Places_Governorates_GovernorateID",
                table: "Places");

            migrationBuilder.DropForeignKey(
                name: "FK_Places_PlaceTypes_PlaceTypeID",
                table: "Places");

            migrationBuilder.AlterColumn<int>(
                name: "PlaceTypeID",
                table: "Places",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<int>(
                name: "GovernorateID",
                table: "Places",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "Places",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<string>(
                name: "Address",
                table: "Places",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddForeignKey(
                name: "FK_Places_Governorates_GovernorateID",
                table: "Places",
                column: "GovernorateID",
                principalTable: "Governorates",
                principalColumn: "GovernorateID");

            migrationBuilder.AddForeignKey(
                name: "FK_Places_PlaceTypes_PlaceTypeID",
                table: "Places",
                column: "PlaceTypeID",
                principalTable: "PlaceTypes",
                principalColumn: "TypeID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Places_Governorates_GovernorateID",
                table: "Places");

            migrationBuilder.DropForeignKey(
                name: "FK_Places_PlaceTypes_PlaceTypeID",
                table: "Places");

            migrationBuilder.AlterColumn<int>(
                name: "PlaceTypeID",
                table: "Places",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "GovernorateID",
                table: "Places",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "Places",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Address",
                table: "Places",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Places_Governorates_GovernorateID",
                table: "Places",
                column: "GovernorateID",
                principalTable: "Governorates",
                principalColumn: "GovernorateID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Places_PlaceTypes_PlaceTypeID",
                table: "Places",
                column: "PlaceTypeID",
                principalTable: "PlaceTypes",
                principalColumn: "TypeID",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
