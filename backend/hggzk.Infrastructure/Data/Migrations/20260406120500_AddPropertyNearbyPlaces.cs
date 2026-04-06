using System;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using YemenBooking.Infrastructure.Data.Context;

#nullable disable

namespace YemenBooking.Infrastructure.Data.Migrations
{
    /// <summary>
    /// Adds managed nearby places for properties.
    /// يضيف الأماكن القريبة المُدارة للعقارات.
    /// </summary>
    [DbContext(typeof(YemenBookingDbContext))]
    [Migration("20260406120500_AddPropertyNearbyPlaces")]
    public class AddPropertyNearbyPlaces : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PropertyNearbyPlaces",
                columns: table => new
                {
                    NearbyPlaceId = table.Column<Guid>(type: "uuid", nullable: false),
                    PropertyId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    NameEn = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    DescriptionEn = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    Category = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Icon = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Latitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: true),
                    Longitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: true),
                    DistanceInMeters = table.Column<int>(type: "integer", nullable: false),
                    WalkingMinutes = table.Column<int>(type: "integer", nullable: true),
                    DrivingMinutes = table.Column<int>(type: "integer", nullable: true),
                    DisplayOrder = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    DeletedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DeletedBy = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertyNearbyPlaces", x => x.NearbyPlaceId);
                    table.ForeignKey(
                        name: "FK_PropertyNearbyPlaces_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PropertyNearbyPlaces_PropertyId",
                table: "PropertyNearbyPlaces",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyNearbyPlaces_PropertyId_DisplayOrder",
                table: "PropertyNearbyPlaces",
                columns: new[] { "PropertyId", "DisplayOrder" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PropertyNearbyPlaces");
        }
    }
}
