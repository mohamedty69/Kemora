using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MimeKit;

namespace Kemora.Infrastructure.Services
{
    public class SmtpEmailService : IEmailService
    {
        private readonly EmailSettings _emailSettings;
        private readonly ILogger<SmtpEmailService> _logger;

        public SmtpEmailService(IOptions<EmailSettings> options, ILogger<SmtpEmailService> logger)
        {
            _emailSettings = options.Value;
            _logger = logger;
        }

        public async Task SendEmailAsync(string to, string subject, string body)
        {
            try
            {
                var email = new MimeMessage();
                email.From.Add(new MailboxAddress(_emailSettings.FromName ?? "Kemora", _emailSettings.FromEmail));
                email.To.Add(MailboxAddress.Parse(to));
                email.Subject = subject;

                var plainText = System.Text.RegularExpressions.Regex.Replace(body, "<.*?>", string.Empty);
                var builder = new BodyBuilder { HtmlBody = body, TextBody = plainText };
                email.Body = builder.ToMessageBody();

                using var smtp = new SmtpClient();
                smtp.CheckCertificateRevocation = false;
                await smtp.ConnectAsync(_emailSettings.Host, _emailSettings.Port, SecureSocketOptions.StartTls);
                
                // Note: since we don't have an OAuth2 token, disable it
                smtp.AuthenticationMechanisms.Remove("XOAUTH2");

                await smtp.AuthenticateAsync(_emailSettings.Username, _emailSettings.Password);
                await smtp.SendAsync(email);
                _logger.LogInformation("Email sent successfully to {To} via {Host}", to, _emailSettings.Host);
                await smtp.DisconnectAsync(true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while sending email to {To}. Configuration used: Host {Host}, Port {Port}, From {From}", to, _emailSettings.Host, _emailSettings.Port, _emailSettings.FromEmail);
                throw;
            }
        }
    }
}
