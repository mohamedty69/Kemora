using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Threading.Tasks;
using Microsoft.AspNetCore.RateLimiting;
using System.Security.Claims;
using System.Text.Json;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Handles user authentication: registration, login, token refresh, email confirmation, and password reset.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [EnableRateLimiting("auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        /// <summary>
        /// Register a new user account.
        /// </summary>
        /// <param name="model">Registration details including full name, email, and password.</param>
        /// <returns>Authentication tokens and user info.</returns>
        [AllowAnonymous]
        [HttpPost("register")]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            var (succeeded, error, data) = await _authService.RegisterAsync(model);
            if (!succeeded) return BadRequest(error);
            return Ok(data);
        }

        /// <summary>
        /// Login with email and password.
        /// </summary>
        /// <param name="model">Login credentials.</param>
        /// <returns>JWT access token and refresh token.</returns>
        [AllowAnonymous]
        [HttpPost("login")]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Login([FromBody] LoginDto model)
        {
            var (succeeded, error, data) = await _authService.LoginAsync(model);
            if (!succeeded) return Unauthorized(error);
            return Ok(data);
        }

        /// <summary>
        /// Login using Google OAuth token.
        /// </summary>
        /// <param name="model">External login details including the provider and ID token.</param>
        /// <returns>JWT access token and refresh token.</returns>
        [AllowAnonymous]
        [HttpPost("google-login")]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginDto model)
        {

            var (succeeded, error, data) = await _authService.GoogleLoginAsync(model.IdToken);
            if (!succeeded) return Unauthorized(error);
            return Ok(data);
        }

        /// <summary>
        /// Refresh an expired JWT token using a valid refresh token.
        /// </summary>
        [HttpPost("refresh")]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequestDto model)
        {
            var (succeeded, error, data) = await _authService.RefreshTokenAsync(model);
            if (!succeeded) return Unauthorized(error);
            return Ok(data);
        }

        /// <summary>
        /// Confirm a user's email address using the confirmation token sent during registration.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("confirm-email")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ConfirmEmail([FromBody] ConfirmEmailDto model)
        {
            var (succeeded, error) = await _authService.ConfirmEmailAsync(model.UserId, model.Token);
            if (!succeeded) return BadRequest(error);
            return Ok(new { message = "Email confirmed successfully." });
        }

        /// <summary>
        /// Confirm email via a direct link (GET request).
        /// </summary>
        [AllowAnonymous]
        [HttpGet("confirm-email-link")]
        public async Task<IActionResult> ConfirmEmailLink([FromQuery] string userId, [FromQuery] string token)
        {
            var (succeeded, error) = await _authService.ConfirmEmailAsync(userId, token);
            
            string title = succeeded ? "Email Verified" : "Verification Failed";
            string icon = succeeded ? "✅" : "❌";
            string color = succeeded ? "#C5A358" : "#e74c3c";
            string message = succeeded 
                ? "Your email has been successfully verified. You can now return to the Kemora app and start your journey." 
                : $"Verification failed: {error}. Please try resending the confirmation email from the app.";

            string html = $@"
<!DOCTYPE html>
<html>
<head>
    <title>{title}</title>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }}
        .card {{ background: white; padding: 40px; border-radius: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); text-align: center; max-width: 400px; width: 90%; }}
        .icon {{ font-size: 64px; margin-bottom: 20px; }}
        h1 {{ color: #1a1a1a; margin-bottom: 16px; font-size: 24px; }}
        p {{ color: #666; line-height: 1.6; margin-bottom: 30px; }}
        .btn {{ background-color: {color}; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block; }}
    </style>
</head>
<body>
    <div class='card'>
        <div class='icon'>{icon}</div>
        <h1>{title}</h1>
        <p>{message}</p>
        <a href='#' onclick='window.close()' class='btn'>Close Window</a>
    </div>
</body>
</html>";

            return Content(html, "text/html");
        }

        /// <summary>
        /// Request a password reset token. An email will be sent if the account exists.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("forgot-password")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto model)
        {
            var (succeeded, error) = await _authService.ForgotPasswordAsync(model.Email);
            return Ok(new { message = "If your email exists, a reset link has been sent." });
        }

        /// <summary>
        /// Redirects the user to the Flutter app's password reset screen.
        /// </summary>
        [AllowAnonymous]
        [HttpGet("reset-password-redirect")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public IActionResult ResetPasswordRedirect([FromQuery] string email, [FromQuery] string token)
        {
            var encodedEmail = Uri.EscapeDataString(email);
            var encodedToken = Uri.EscapeDataString(token);
            // Kemora deep link scheme intercepted by the Flutter app
            return Redirect($"kemora://reset-password?email={encodedEmail}&token={encodedToken}");
        }

        /// <summary>
        /// Reset a user's password using the token received via email.
        /// </summary>
        [HttpPost("reset-password")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto model)
        {
            var (succeeded, error) = await _authService.ResetPasswordAsync(model.Email, model.Token, model.NewPassword);
            if (!succeeded) return BadRequest(error);
            return Ok(new { message = "Password reset successfully." });
        }

        /// <summary>
        /// Manually trigger an email confirmation for a user (Admin only).
        /// </summary>
        [HttpPost("admin/send-confirmation")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ResendConfirmation([FromQuery] string email)
        {
            var (succeeded, error) = await _authService.SendEmailConfirmationAsync(email);
            if (!succeeded) return BadRequest(error);
            return Ok(new { message = "Confirmation email sent." });
        }
        [Authorize]
        [HttpPost("preferences")]
        public async Task<IActionResult> UpdatePreferences([FromBody] JsonElement preferences)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _authService.UpdatePreferencesAsync(userId, preferences.GetRawText());
            if (!result.Succeeded) return BadRequest(result.Error);

            return Ok(new { message = "Preferences updated successfully" });
        }

        /// <summary>
        /// Change the authenticated user's password.
        /// </summary>
        [HttpPost("change-password")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var (succeeded, error) = await _authService.ChangePasswordAsync(userId, dto.CurrentPassword, dto.NewPassword);
            if (!succeeded) return BadRequest(error);
            
            return Ok(new { message = "Password changed successfully." });
        }

        /// <summary>
        /// Change the authenticated user's email address.
        /// </summary>
        [HttpPost("change-email")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ChangeEmail([FromBody] ChangeEmailDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var (succeeded, error) = await _authService.ChangeEmailAsync(userId, dto.NewEmail, dto.Password);
            if (!succeeded) return BadRequest(error);
            
            return Ok(new { message = "Email changed successfully." });
        }

        /// <summary>
        /// Logout the authenticated user and invalidate their refresh token.
        /// </summary>
        [HttpPost("logout")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> Logout()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var (succeeded, error) = await _authService.LogoutAsync(userId);
            if (!succeeded) return BadRequest(error);

            return Ok(new { message = "Logged out successfully." });
        }
    }
}