using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace Kemora.Api.Controllers
{
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class ChatsController : ControllerBase
    {
        private readonly IChatService _chatService;

        public ChatsController(IChatService chatService)
        {
            _chatService = chatService;
        }

        private string GetUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        [HttpPost("send")]
        public async Task<ActionResult<MessageDto>> SendMessage([FromBody] SendMessageDto dto)
        {
            return Ok(await _chatService.SendMessageAsync(GetUserId(), dto));
        }

        [HttpGet("conversations")]
        public async Task<ActionResult<List<ConversationDto>>> GetConversations()
        {
            return Ok(await _chatService.GetConversationsAsync(GetUserId()));
        }

        [HttpGet("conversation/{contactId}")]
        public async Task<ActionResult<List<MessageDto>>> GetConversation(string contactId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
        {
            return Ok(await _chatService.GetConversationAsync(GetUserId(), contactId, page, pageSize));
        }

        [HttpPost("read/{contactId}")]
        public async Task<IActionResult> MarkAsRead(string contactId)
        {
            await _chatService.MarkAsReadAsync(GetUserId(), contactId);
            return Ok();
        }
    }
}
