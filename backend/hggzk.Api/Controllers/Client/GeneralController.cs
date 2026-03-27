using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Reports.Commands.SubmitFeedback;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetAppVersion;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetCurrencyExchangeRate;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetFAQs;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetPrivacyPolicy;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetTermsAndConditions;
using AppVersionDto = YemenBooking.Application.Features.SearchAndFilters.Queries.GetAppVersion.AppVersionDto;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم الوظائف العامة الموجهة للعميل.
    /// Client-facing general functions controller.
    /// </summary>
    public class GeneralController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [GeneralController].
        /// Initializes a new instance of [GeneralController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لتنفيذ الاستعلامات والأوامر. MediatR mediator used for requests.</param>
        public GeneralController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يرسل ملاحظات أو اقتراحات من المستخدم.
        /// Submits user feedback or suggestions.
        /// </summary>
        /// <param name="command">بيانات الملاحظات. Feedback details.</param>
        /// <returns>نتيجة الإرسال. Submission result.</returns>
        [HttpPost("feedback")]
        public async Task<ActionResult<ResultDto<SubmitFeedbackResponse>>> SubmitFeedback([FromBody] SubmitFeedbackCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد الإصدار الحالي للتطبيق.
        /// Returns the current application version.
        /// </summary>
        /// <returns>معلومات الإصدار. Version information.</returns>
        [HttpGet("app-version")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<AppVersionDto>>> GetAppVersion([FromQuery] GetAppVersionQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد سعر صرف العملة.
        /// Returns the currency exchange rate.
        /// </summary>
        /// <param name="query">معايير العملة. Currency parameters.</param>
        /// <returns>سعر الصرف. Exchange rate.</returns>
        [HttpGet("currency-exchange")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<CurrencyExchangeRateDto>>> GetCurrencyExchangeRate([FromQuery] GetCurrencyExchangeRateQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد الأسئلة الشائعة.
        /// Returns frequently asked questions.
        /// </summary>
        /// <returns>قائمة الأسئلة الشائعة. FAQ list.</returns>
        [HttpGet("faqs")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<List<FAQCategoryDto>>>> GetFAQs([FromQuery] GetFAQsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد سياسة الخصوصية.
        /// Returns the privacy policy.
        /// </summary>
        /// <returns>سياسة الخصوصية. Privacy policy document.</returns>
        [HttpGet("privacy-policy")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<LegalDocumentDto>>> GetPrivacyPolicy([FromQuery] GetPrivacyPolicyQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد الشروط والأحكام.
        /// Returns the terms and conditions.
        /// </summary>
        /// <returns>الشروط والأحكام. Terms and conditions document.</returns>
        [HttpGet("terms-and-conditions")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<LegalDocumentDto>>> GetTermsAndConditions([FromQuery] GetTermsAndConditionsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
