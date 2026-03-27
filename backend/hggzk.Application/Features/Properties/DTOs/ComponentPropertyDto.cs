using System;

namespace YemenBooking.Application.Features.Properties.DTOs
{
    /// <summary>
    /// فئة ComponentPropertyDto.
    /// ComponentPropertyDto class.
    /// </summary>
    public class ComponentPropertyDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية PropertyKey.
        /// PropertyKey property.
        /// </summary>
        public string PropertyKey { get; set; }
        /// <summary>
        /// خاصية PropertyName.
        /// PropertyName property.
        /// </summary>
        public string PropertyName { get; set; }
        /// <summary>
        /// خاصية PropertyType.
        /// PropertyType property.
        /// </summary>
        public string PropertyType { get; set; }
        /// <summary>
        /// خاصية Value.
        /// Value property.
        /// </summary>
        public string Value { get; set; }
        /// <summary>
        /// خاصية DefaultValue.
        /// DefaultValue property.
        /// </summary>
        public string DefaultValue { get; set; }
        /// <summary>
        /// خاصية IsRequired.
        /// IsRequired property.
        /// </summary>
        public bool IsRequired { get; set; }
        /// <summary>
        /// خاصية ValidationRules.
        /// ValidationRules property.
        /// </summary>
        public string ValidationRules { get; set; }
        /// <summary>
        /// خاصية Options.
        /// Options property.
        /// </summary>
        public string Options { get; set; }
        /// <summary>
        /// خاصية HelpText.
        /// HelpText property.
        /// </summary>
        public string HelpText { get; set; }
        /// <summary>
        /// خاصية Order.
        /// Order property.
        /// </summary>
        public int Order { get; set; }
    }
}