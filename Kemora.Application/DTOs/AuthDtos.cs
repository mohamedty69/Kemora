using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class RegisterDto
    {
        [Required(ErrorMessage = "Full name is required.")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Full name must be between 3 and 100 characters.")]
        public string FullName { get; set; }

        [Required(ErrorMessage = "Email address is required.")]
        [EmailAddress(ErrorMessage = "Invalid email address format.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Country or region is required.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Country must be between 2 and 100 characters.")]
        public string Country { get; set; }

        [Required(ErrorMessage = "Password is required.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be at least 8 characters long.")]
        public string Password { get; set; }
    }

    public class LoginDto
    {
        [Required(ErrorMessage = "Email address is required.")]
        [EmailAddress(ErrorMessage = "Invalid email address format.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required.")]
        public string Password { get; set; }
    }

    public class GoogleLoginDto
    {
        [Required(ErrorMessage = "ID Token is required.")]
        public string IdToken { get; set; }
    }

    public class AuthResponseDto
    {
        public string UserId { get; set; }
        public string FullName { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public string Country { get; set; }
        public string Email { get; set; }
        public string Token { get; set; }
        public string RefreshToken { get; set; }
    }

    public class RefreshTokenRequestDto
    {
        [Required(ErrorMessage = "Access token is required.")]
        public string Token { get; set; }

        [Required(ErrorMessage = "Refresh token is required.")]
        public string RefreshToken { get; set; }
    }

    public class ForgotPasswordDto
    {
        [Required(ErrorMessage = "Email address is required.")]
        [EmailAddress(ErrorMessage = "Invalid email address format.")]
        public string Email { get; set; }
    }

    public class ResetPasswordDto
    {
        [Required(ErrorMessage = "Email address is required.")]
        [EmailAddress(ErrorMessage = "Invalid email address format.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Reset token is required.")]
        public string Token { get; set; }

        [Required(ErrorMessage = "New password is required.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "New password must be at least 8 characters long.")]
        public string NewPassword { get; set; }
    }

    public class ConfirmEmailDto
    {
        [Required(ErrorMessage = "User ID is required.")]
        public string UserId { get; set; }

        [Required(ErrorMessage = "Confirmation token is required.")]
        public string Token { get; set; }
    }

    public class ChangePasswordDto
    {
        [Required(ErrorMessage = "Current password is required.")]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "New password is required.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "New password must be at least 8 characters long.")]
        public string NewPassword { get; set; } = string.Empty;
    }

    public class ChangeEmailDto
    {
        [Required(ErrorMessage = "New email address is required.")]
        [EmailAddress(ErrorMessage = "Invalid email address format.")]
        public string NewEmail { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required to confirm email change.")]
        public string Password { get; set; } = string.Empty;
    }
}
