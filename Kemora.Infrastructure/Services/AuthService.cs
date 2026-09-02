using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using AutoMapper;
using System.Security.Claims;
using Google.Apis.Auth;
using Microsoft.Extensions.Configuration;
using System.Web;

namespace Kemora.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly ITokenService _tokenService;
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;
        private readonly IMapper _mapper;
        private readonly IConfiguration _configuration;

        public AuthService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            ITokenService tokenService,
            ApplicationDbContext context,
            IEmailService emailService,
            IMapper mapper,
            IConfiguration configuration)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _tokenService = tokenService;
            _context = context;
            _emailService = emailService;
            _mapper = mapper;
            _configuration = configuration;
        }

        public async Task<(bool Succeeded, string Error, AuthResponseDto Data)> RegisterAsync(RegisterDto model)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                if (await _userManager.FindByEmailAsync(model.Email) != null)
                    return (false, "Email already exists", null);

                var user = new ApplicationUser
                {
                    UserName = model.Email,
                    Email = model.Email,
                    FullName = model.FullName,
                    Country = model.Country,
                    TotalPoints = 50
                };

                var result = await _userManager.CreateAsync(user, model.Password);
                if (!result.Succeeded)
                    return (false, string.Join(", ", result.Errors.Select(e => e.Description)), null);

                // Assign roles
                var admins = await _userManager.GetUsersInRoleAsync("Admin");
                if (admins.Count == 0)
                {
                    await _userManager.AddToRoleAsync(user, "Admin");
                }
                else
                {
                    await _userManager.AddToRoleAsync(user, "User");
                }
                user.RefreshToken = _tokenService.GenerateRefreshToken();
                user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
                await _userManager.UpdateAsync(user);

                var token = await _tokenService.CreateTokenAsync(user);
                await transaction.CommitAsync();

                // [FIX] Send welcome email AFTER committing — isolated in its own try/catch.
                // SMTP misconfiguration (wrong credentials, placeholder username, etc.)
                // must NEVER roll back a successfully created user account.
                try
                {
                    var emailToken = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                    var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:7210";
                    var confirmationLink = $"{baseUrl}/api/v1/auth/confirm-email-link?userId={user.Id}&token={Uri.EscapeDataString(emailToken)}";
                    await _emailService.SendEmailAsync(user.Email!, "Welcome to Kemora - Confirm Your Email",
                        GetHtmlVerificationEmail(user.FullName, confirmationLink));
                }
                catch (Exception emailEx)
                {
                    // Log warning but do NOT fail registration — user can re-request from settings.
                    Console.WriteLine($"[WARN] Welcome email failed for {user.Email}: {emailEx.Message}");
                }

                var response = _mapper.Map<AuthResponseDto>(user);
                response.Token = token;

                return (true, null, response);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return (false, "Registration failed: " + ex.Message, null);
            }
        }

        public async Task<(bool Succeeded, string Error, AuthResponseDto Data)> LoginAsync(LoginDto model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null) return (false, "Invalid Email", null);

            var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);
            if (!result.Succeeded) return (false, "Invalid Password", null);

            user.RefreshToken = _tokenService.GenerateRefreshToken();
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
            await _userManager.UpdateAsync(user);

            var token = await _tokenService.CreateTokenAsync(user);

            var response = _mapper.Map<AuthResponseDto>(user);
            response.Token = token;

            return (true, null, response);
        }

        public async Task<(bool Succeeded, string Error, AuthResponseDto Data)> GoogleLoginAsync(string idToken)
        {
            try
            {
                var settings = new GoogleJsonWebSignature.ValidationSettings();
                var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);
                if (payload == null)
                    return (false, "Invalid Google token.", null);

                var user = await _userManager.FindByEmailAsync(payload.Email);
                if (user == null)
                {
                    user = new ApplicationUser
                    {
                        UserName = payload.Email,
                        Email = payload.Email,
                        FullName = payload.Name,
                        EmailConfirmed = payload.EmailVerified,
                        TotalPoints = 50
                    };

                    var result = await _userManager.CreateAsync(user);
                    if (!result.Succeeded)
                        return (false, string.Join(", ", result.Errors.Select(e => e.Description)), null);

                    var admins = await _userManager.GetUsersInRoleAsync("Admin");
                    if (admins.Count == 0)
                    {
                        await _userManager.AddToRoleAsync(user, "Admin");
                    }
                    else
                    {
                        await _userManager.AddToRoleAsync(user, "User");
                    }
                }

                user.RefreshToken = _tokenService.GenerateRefreshToken();
                user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
                await _userManager.UpdateAsync(user);

                var token = await _tokenService.CreateTokenAsync(user);
                var response = _mapper.Map<AuthResponseDto>(user);
                response.Token = token;

                return (true, null, response);
            }
            catch (InvalidJwtException)
            {
                return (false, "Invalid Google token.", null);
            }
            catch (Exception ex)
            {
                return (false, "Google login failed: " + ex.Message, null);
            }
        }

        public async Task<(bool Succeeded, string Error, AuthResponseDto Data)> RefreshTokenAsync(RefreshTokenRequestDto model)
        {
            var user = _userManager.Users.FirstOrDefault(u => u.RefreshToken == model.RefreshToken);
            if (user == null || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
                return (false, "Invalid or expired refresh token", null);

            user.RefreshToken = _tokenService.GenerateRefreshToken();
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
            await _userManager.UpdateAsync(user);

            var newToken = await _tokenService.CreateTokenAsync(user);
            var response = _mapper.Map<AuthResponseDto>(user);
            response.Token = newToken;

            return (true, null, response);
        }

        public async Task<(bool Succeeded, string Error)> ConfirmEmailAsync(string userId, string token)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return (false, "User not found");

            var result = await _userManager.ConfirmEmailAsync(user, token);
            if (!result.Succeeded)
                return (false, string.Join(", ", result.Errors.Select(e => e.Description)));

            return (true, null!);
        }

        public async Task<(bool Succeeded, string Error)> ForgotPasswordAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null) return (true, null!); // Don't reveal that user doesn't exist

            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:7210";
            var encodedToken = Uri.EscapeDataString(token);
            var encodedEmail = Uri.EscapeDataString(email);
            var resetLink = $"{baseUrl}/api/v1/auth/reset-password-redirect?email={encodedEmail}&token={encodedToken}";

            await _emailService.SendEmailAsync(email, "Reset Your Kemora Password",
                GetHtmlPasswordResetEmail(user.FullName, resetLink));

            return (true, null!);
        }

        public async Task<(bool Succeeded, string Error)> ResetPasswordAsync(string email, string token, string newPassword)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null) return (false, "User not found");

            var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
            if (!result.Succeeded)
                return (false, string.Join(", ", result.Errors.Select(e => e.Description)));

            return (true, null!);
        }

        public async Task<(bool Succeeded, string Error)> SendEmailConfirmationAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null) return (false, "User not found");

            var token = await _userManager.GenerateEmailConfirmationTokenAsync(user);
            var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:7210";
            var confirmationLink = $"{baseUrl}/api/v1/auth/confirm-email-link?userId={user.Id}&token={Uri.EscapeDataString(token)}";

            await _emailService.SendEmailAsync(user.Email!, "Confirm your Kemora email",
                GetHtmlVerificationEmail(user.FullName, confirmationLink));

            return (true, null!);
        }

        public async Task<(bool Succeeded, string Error)> ChangePasswordAsync(string userId, string currentPassword, string newPassword)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return (false, "User not found.");

            var result = await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);
            if (!result.Succeeded)
                return (false, string.Join(", ", result.Errors.Select(e => e.Description)));

            return (true, null!);
        }

        public async Task<(bool Succeeded, string Error)> ChangeEmailAsync(string userId, string newEmail, string password)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return (false, "User not found.");

            var passwordCorrect = await _userManager.CheckPasswordAsync(user, password);
            if (!passwordCorrect) return (false, "Incorrect password.");

            var emailExists = await _userManager.FindByEmailAsync(newEmail);
            if (emailExists != null) return (false, "Email is already taken.");

            var token = await _userManager.GenerateChangeEmailTokenAsync(user, newEmail);
            var result = await _userManager.ChangeEmailAsync(user, newEmail, token);
            if (!result.Succeeded)
                return (false, string.Join(", ", result.Errors.Select(e => e.Description)));

            user.UserName = newEmail;
            await _userManager.UpdateAsync(user);

            return (true, null!);
        }

        public async Task<(bool Succeeded, string Error)> LogoutAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return (false, "User not found.");

            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = DateTime.UtcNow;
            await _userManager.UpdateAsync(user);

            return (true, null!);
        }

        private string GetHtmlPasswordResetEmail(string name, string link)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <style>
        body {{ font-family: 'Helvetica Neue', Arial, sans-serif; background-color: #f4f7f6; margin: 0; padding: 0; }}
        .wrapper {{ width: 100%; background-color: #f4f7f6; padding: 40px 0; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }}
        .header {{ background-color: #1A1A1A; padding: 30px; text-align: center; }}
        .logo {{ font-size: 28px; font-weight: 800; color: #C5A358; letter-spacing: 2px; text-transform: uppercase; margin: 0; }}
        .content {{ padding: 40px; text-align: center; color: #4a4a4a; line-height: 1.6; }}
        h1 {{ color: #2c3e50; font-size: 24px; margin-top: 0; margin-bottom: 20px; font-weight: 700; }}
        p {{ margin-bottom: 20px; font-size: 16px; color: #555555; }}
        .button-container {{ margin: 35px 0; }}
        .button {{ background-color: #e74c3c; color: #ffffff !important; padding: 15px 35px; text-decoration: none; border-radius: 8px; font-weight: bold; font-size: 16px; display: inline-block; transition: background-color 0.3s ease; box-shadow: 0 4px 6px rgba(231, 76, 60, 0.2); }}
        .button:hover {{ background-color: #c0392b; box-shadow: 0 6px 12px rgba(231, 76, 60, 0.3); }}
        .link-fallback {{ background: #f9f9f9; padding: 15px; border-radius: 8px; border: 1px dashed #dddddd; margin-top: 15px; word-break: break-all; font-size: 13px; color: #777777; }}
        .link-url {{ color: #C5A358; text-decoration: none; font-weight: 500; }}
        .warning {{ background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; border-radius: 4px; font-size: 14px; text-align: left; color: #856404; margin-top: 30px; }}
        .footer {{ background-color: #fcfcfc; text-align: center; padding: 25px; border-top: 1px solid #eeeeee; font-size: 13px; color: #888888; }}
    </style>
</head>
<body>
    <div class='wrapper'>
        <div class='container'>
            <div class='header'>
                <h2 class='logo'>KEMORA</h2>
            </div>
            <div class='content'>
                <h1>Password Reset Request</h1>
                <p>Hi {name},</p>
                <p>We received a request to reset your password. Click the button below to choose a new one:</p>
                
                <div class='button-container'>
                    <a href='{link}' class='button'>Reset My Password</a>
                </div>
                
                <div class='warning'>⚠️ <strong>Note:</strong> This link will expire in 24 hours. If you did not request a password reset, you can safely ignore this email.</div>
                
                <p style='font-size: 14px; color: #777; margin-top: 30px;'>If the button doesn't work, copy and paste this link into your browser:</p>
                <div class='link-fallback'>
                    <a href='{link}' class='link-url'>{link}</a>
                </div>
            </div>
            <div class='footer'>
                &copy; {DateTime.UtcNow.Year} Kemora Tourism. All rights reserved.
            </div>
        </div>
    </div>
</body>
</html>";
        }

        private string GetHtmlVerificationEmail(string name, string link)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <style>
        body {{ font-family: 'Helvetica Neue', Arial, sans-serif; background-color: #f4f7f6; margin: 0; padding: 0; }}
        .wrapper {{ width: 100%; background-color: #f4f7f6; padding: 40px 0; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }}
        .header {{ background-color: #1A1A1A; padding: 30px; text-align: center; }}
        .logo {{ font-size: 28px; font-weight: 800; color: #C5A358; letter-spacing: 2px; text-transform: uppercase; margin: 0; }}
        .content {{ padding: 40px; text-align: center; color: #4a4a4a; line-height: 1.6; }}
        h1 {{ color: #2c3e50; font-size: 24px; margin-top: 0; margin-bottom: 20px; font-weight: 700; }}
        p {{ margin-bottom: 20px; font-size: 16px; color: #555555; }}
        .button-container {{ margin: 35px 0; }}
        .button {{ background-color: #C5A358; color: #ffffff !important; padding: 15px 35px; text-decoration: none; border-radius: 8px; font-weight: bold; font-size: 16px; display: inline-block; transition: background-color 0.3s ease; box-shadow: 0 4px 6px rgba(197, 163, 88, 0.2); }}
        .button:hover {{ background-color: #b39147; box-shadow: 0 6px 12px rgba(197, 163, 88, 0.3); }}
        .link-fallback {{ background: #f9f9f9; padding: 15px; border-radius: 8px; border: 1px dashed #dddddd; margin-top: 15px; word-break: break-all; font-size: 13px; color: #777777; }}
        .link-url {{ color: #C5A358; text-decoration: none; font-weight: 500; }}
        .footer {{ background-color: #fcfcfc; text-align: center; padding: 25px; border-top: 1px solid #eeeeee; font-size: 13px; color: #888888; }}
    </style>
</head>
<body>
    <div class='wrapper'>
        <div class='container'>
            <div class='header'>
                <h2 class='logo'>KEMORA</h2>
            </div>
            <div class='content'>
                <h1>Welcome to the Journey, {name}!</h1>
                <p>Thank you for joining Kemora, your ultimate guide to exploring the wonders of Egypt. We're thrilled to have you on board!</p>
                <p>To start planning your dream trips and connecting with other travelers, please verify your email address by clicking the button below:</p>
                
                <div class='button-container'>
                    <a href='{link}' class='button'>Verify My Account</a>
                </div>
                
                <p style='font-size: 14px; color: #777;'>If the button doesn't work, you can copy and paste this link into your browser:</p>
                <div class='link-fallback'>
                    <a href='{link}' class='link-url'>{link}</a>
                </div>
                
                <p style='margin-top: 35px; margin-bottom: 0;'>See you in Egypt!<br><strong style='color: #1A1A1A;'>The Kemora Team</strong></p>
            </div>
            <div class='footer'>
                &copy; {DateTime.UtcNow.Year} Kemora Tourism. All rights reserved.<br>
                You received this email because you signed up for Kemora.
            </div>
        </div>
    </div>
</body>
</html>";
        }

        public async Task<(bool Succeeded, string Error)> UpdatePreferencesAsync(string userId, string preferencesJson)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return (false, "User not found");

            user.UserPreferencesJSON = preferencesJson;
            var result = await _userManager.UpdateAsync(user);

            if (!result.Succeeded)
                return (false, string.Join(", ", result.Errors.Select(e => e.Description)));

            return (true, null!);
        }
    }
}
