using System;
using YemenBooking.Core.Interfaces;

namespace YemenBooking.Core.Interfaces.Events
{
    #region Payment Events
    /// <summary>
    /// واجهة IPaymentProcessedEvent.
    /// IPaymentProcessedEvent interface.
    /// </summary>
    public interface IPaymentProcessedEvent : IDomainEvent { }
    /// <summary>
    /// واجهة IPaymentRefundedEvent.
    /// IPaymentRefundedEvent interface.
    /// </summary>
    public interface IPaymentRefundedEvent : IDomainEvent { }
    /// <summary>
    /// واجهة IPaymentStatusUpdatedEvent.
    /// IPaymentStatusUpdatedEvent interface.
    /// </summary>
    public interface IPaymentStatusUpdatedEvent : IDomainEvent { }
    /// <summary>
    /// واجهة IPaymentFailedEvent.
    /// IPaymentFailedEvent interface.
    /// </summary>
    public interface IPaymentFailedEvent : IDomainEvent { }
    #endregion

    #region Booking Events
    /// <summary>
    /// واجهة IBookingCreatedEvent.
    /// IBookingCreatedEvent interface.
    /// </summary>
    public interface IBookingCreatedEvent : IDomainEvent { }
    /// <summary>
    /// واجهة IBookingConfirmedEvent.
    /// IBookingConfirmedEvent interface.
    /// </summary>
    public interface IBookingConfirmedEvent : IDomainEvent { }
    /// <summary>
    /// واجهة IBookingUpdatedEvent.
    /// IBookingUpdatedEvent interface.
    /// </summary>
    public interface IBookingUpdatedEvent : IDomainEvent { }
    #endregion
}
