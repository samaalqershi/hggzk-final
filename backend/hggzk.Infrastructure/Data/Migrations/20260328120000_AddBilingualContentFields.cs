using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using YemenBooking.Infrastructure.Data.Context;

#nullable disable

namespace YemenBooking.Infrastructure.Data.Migrations
{
    /// <summary>
    /// Adds bilingual persisted content fields for core catalog entities.
    /// يضيف حقول محتوى ثنائية اللغة للكيانات الأساسية في الكتالوج.
    /// </summary>
    [DbContext(typeof(YemenBookingDbContext))]
    [Migration("20260328120000_AddBilingualContentFields")]
    public class AddBilingualContentFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "Amenities",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "Amenities",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CountryEn",
                table: "Cities",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "Cities",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "FieldGroups",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DisplayNameEn",
                table: "FieldGroups",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "GroupNameEn",
                table: "FieldGroups",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "AddressEn",
                table: "Properties",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CityEn",
                table: "Properties",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "Properties",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "Properties",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ShortDescriptionEn",
                table: "Properties",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CancellationPenaltyAfterDeadlineEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CheckInEarlyCheckInNoteEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CheckInLateCheckOutFeeEn",
                table: "PropertyPolicies",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CheckInLateCheckOutNoteEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ChildrenCribsNoteEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ModificationFeesAfterEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ModificationReasonEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PetsMaxWeightEn",
                table: "PropertyPolicies",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PetsReasonEn",
                table: "PropertyPolicies",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RulesEn",
                table: "PropertyPolicies",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "PropertyServices",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "PropertyServices",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "PropertyTypes",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "PropertyTypes",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DisplayNameEn",
                table: "SearchFilters",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FilterOptionsEn",
                table: "SearchFilters",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CustomFeaturesEn",
                table: "Units",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "Units",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "UnitTypes",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "UnitTypes",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CategoryEn",
                table: "UnitTypeFields",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "UnitTypeFields",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DisplayNameEn",
                table: "UnitTypeFields",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FieldOptionsEn",
                table: "UnitTypeFields",
                type: "text",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cities_NameEn",
                table: "Cities",
                column: "NameEn");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyServices_NameEn",
                table: "PropertyServices",
                column: "NameEn");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Cities_NameEn",
                table: "Cities");

            migrationBuilder.DropIndex(
                name: "IX_PropertyServices_NameEn",
                table: "PropertyServices");

            migrationBuilder.DropColumn(name: "DescriptionEn", table: "Amenities");
            migrationBuilder.DropColumn(name: "NameEn", table: "Amenities");
            migrationBuilder.DropColumn(name: "CountryEn", table: "Cities");
            migrationBuilder.DropColumn(name: "NameEn", table: "Cities");
            migrationBuilder.DropColumn(name: "DescriptionEn", table: "FieldGroups");
            migrationBuilder.DropColumn(name: "DisplayNameEn", table: "FieldGroups");
            migrationBuilder.DropColumn(name: "GroupNameEn", table: "FieldGroups");
            migrationBuilder.DropColumn(name: "AddressEn", table: "Properties");
            migrationBuilder.DropColumn(name: "CityEn", table: "Properties");
            migrationBuilder.DropColumn(name: "DescriptionEn", table: "Properties");
            migrationBuilder.DropColumn(name: "NameEn", table: "Properties");
            migrationBuilder.DropColumn(name: "ShortDescriptionEn", table: "Properties");
            migrationBuilder.DropColumn(name: "CancellationPenaltyAfterDeadlineEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "CheckInEarlyCheckInNoteEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "CheckInLateCheckOutFeeEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "CheckInLateCheckOutNoteEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "ChildrenCribsNoteEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "DescriptionEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "ModificationFeesAfterEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "ModificationReasonEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "PetsMaxWeightEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "PetsReasonEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "RulesEn", table: "PropertyPolicies");
            migrationBuilder.DropColumn(name: "DescriptionEn", table: "PropertyServices");
            migrationBuilder.DropColumn(name: "NameEn", table: "PropertyServices");
            migrationBuilder.DropColumn(name: "DescriptionEn", table: "PropertyTypes");
            migrationBuilder.DropColumn(name: "NameEn", table: "PropertyTypes");
            migrationBuilder.DropColumn(name: "DisplayNameEn", table: "SearchFilters");
            migrationBuilder.DropColumn(name: "FilterOptionsEn", table: "SearchFilters");
            migrationBuilder.DropColumn(name: "CustomFeaturesEn", table: "Units");
            migrationBuilder.DropColumn(name: "NameEn", table: "Units");
            migrationBuilder.DropColumn(name: "DescriptionEn", table: "UnitTypes");
            migrationBuilder.DropColumn(name: "NameEn", table: "UnitTypes");
            migrationBuilder.DropColumn(name: "CategoryEn", table: "UnitTypeFields");
            migrationBuilder.DropColumn(name: "DescriptionEn", table: "UnitTypeFields");
            migrationBuilder.DropColumn(name: "DisplayNameEn", table: "UnitTypeFields");
            migrationBuilder.DropColumn(name: "FieldOptionsEn", table: "UnitTypeFields");
        }
    }
}
