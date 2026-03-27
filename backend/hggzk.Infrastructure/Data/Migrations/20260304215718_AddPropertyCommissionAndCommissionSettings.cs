using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YemenBooking.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddPropertyCommissionAndCommissionSettings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "SystemCommissionRate",
                table: "Properties",
                type: "numeric(5,2)",
                precision: 5,
                scale: 2,
                nullable: true,
                comment: "نسبة عمولة المنصة المخصصة للعقار (0-100)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SystemCommissionRate",
                table: "Properties");
        }
    }
}
