using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class BadgeService : IBadgeService
    {
        private readonly IBadgeRepository _badgeRepo;
        private readonly IUserRepository _userRepo;
        private readonly IRepository<UserBadge> _userBadgeRepo;
        private readonly IRepository<UserPoint> _userPointRepo;
        private readonly IMapper _mapper;

        private readonly IUnitOfWork _unitOfWork;
        private readonly ICacheService _cacheService;

        public BadgeService(IBadgeRepository badgeRepo, IUserRepository userRepo, IRepository<UserBadge> userBadgeRepo, IRepository<UserPoint> userPointRepo, IMapper mapper, IUnitOfWork unitOfWork, ICacheService cacheService)
        {
            _badgeRepo = badgeRepo;
            _userRepo = userRepo;
            _userBadgeRepo = userBadgeRepo;
            _userPointRepo = userPointRepo;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _cacheService = cacheService;
        }

        public async Task<BadgeResponseDto> CreateBadgeAsync(CreateBadgeDto dto)
        {
            var badge = new Badge { Name = dto.Name, Description = dto.Description, PointsReward = dto.PointsReward };
            await _badgeRepo.AddAsync(badge);
            await _unitOfWork.CommitAsync();
            return _mapper.Map<BadgeResponseDto>(badge);
        }

        public async Task<List<BadgeResponseDto>> GetAllBadgesAsync()
        {
            var badges = await _badgeRepo.GetAllAsync();
            return _mapper.Map<List<BadgeResponseDto>>(badges);
        }

        public async Task<List<UserBadgeResponseDto>> GetMyBadgesAsync(string userId)
        {
            var ub = await _userBadgeRepo.FindAsync(u => u.UserID == userId, u => u.Badge);
            return _mapper.Map<List<UserBadgeResponseDto>>(ub);
        }

        public async Task<PointsSummaryDto> GetMyPointsAsync(string userId)
        {
            var user = await _userRepo.GetByIdAsync(userId);
            if (user == null) return new PointsSummaryDto();

            var history = await _userPointRepo.GetSortedAsync(up => up.UserID == userId, q => q.OrderByDescending(up => up.GainedAt), up => up.SourcePlace);
            var resultHistory = _mapper.Map<List<PointHistoryDto>>(history);

            return new PointsSummaryDto { TotalPoints = user.TotalPoints, History = resultHistory };
        }

        public async Task<List<LeaderboardEntryDto>> GetLeaderboardAsync(int top)
        {
            var cacheKey = $"leaderboard_{top}";
            var cachedLeaderboard = _cacheService.Get<List<LeaderboardEntryDto>>(cacheKey);
            
            if (cachedLeaderboard != null)
                return cachedLeaderboard;

            var users = await _userRepo.GetPagedAsync(null, q => q.OrderByDescending(u => u.TotalPoints), 1, top);
            var leaderboard = new List<LeaderboardEntryDto>();
            int rank = 1;
            foreach (var u in users)
            {
                var entry = _mapper.Map<LeaderboardEntryDto>(u);
                entry.Rank = rank++;
                leaderboard.Add(entry);
            }

            _cacheService.Set(cacheKey, leaderboard, System.TimeSpan.FromMinutes(10));
            return leaderboard;
        }
    }
}
