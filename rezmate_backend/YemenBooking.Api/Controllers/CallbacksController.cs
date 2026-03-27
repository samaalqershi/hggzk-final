using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace YemenBooking.Api.Controllers
{
    [ApiController]
    [Route("callbacks")]
    public class CallbacksController : ControllerBase
    {
        [AllowAnonymous]
        [HttpGet("sign_in_with_apple/{app}")]
        [HttpPost("sign_in_with_apple/{app}")]
        public IActionResult AppleSignInCallback([FromRoute] string app)
        {
            var packageId = app?.Trim().ToLowerInvariant() switch
            {
                "hggzk" => "com.hggzk.app",
                "rezmate" => "com.arma.rezmate",
                "rezmateportal" => "com.rezmateportal.app",
                _ => null,
            };

            if (string.IsNullOrWhiteSpace(packageId))
            {
                return BadRequest("Unknown app");
            }

            var parameters = new Dictionary<string, string>(StringComparer.Ordinal);

            foreach (var kv in Request.Query)
            {
                parameters[kv.Key] = kv.Value.ToString();
            }

            if (Request.HasFormContentType)
            {
                foreach (var kv in Request.Form)
                {
                    parameters[kv.Key] = kv.Value.ToString();
                }
            }

            var queryString = QueryString.Create(parameters).ToUriComponent();
            var intentUrl = $"intent://callback{queryString}#Intent;package={packageId};scheme=signinwithapple;end";

            var html = $"<!DOCTYPE html><html><head><meta charset=\"utf-8\"/><meta http-equiv=\"refresh\" content=\"0;url={intentUrl}\"/></head><body><a href=\"{intentUrl}\">Continue</a></body></html>";
            return Content(html, "text/html");
        }
    }
}
