using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LibrarySeatTrackingAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddStaffNoteToReservation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "StaffNote",
                table: "Reservations",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StaffNote",
                table: "Reservations");
        }
    }
}
