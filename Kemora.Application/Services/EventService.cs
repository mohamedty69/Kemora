using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class EventService : IEventService
    {
        private readonly IEventRepository _eventRepo;
        private readonly IPlaceRepository _placeRepo;
        private readonly IMapper _mapper;

        private readonly IUnitOfWork _unitOfWork;

        public EventService(IEventRepository eventRepo, IPlaceRepository placeRepo, IMapper mapper, IUnitOfWork unitOfWork)
        {
            _eventRepo = eventRepo;
            _placeRepo = placeRepo;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }

        public async Task<EventResponseDto?> CreateEventAsync(int placeId, CreateEventDto dto)
        {
            if (!await _placeRepo.ExistsAsync(placeId)) return null;

            var e = new Event { Name = dto.Name, StartDate = dto.StartDate, EndDate = dto.EndDate, PlaceID = placeId };
            await _eventRepo.AddAsync(e);
            await _unitOfWork.CommitAsync();
            return _mapper.Map<EventResponseDto>(e);
        }

        public async Task<List<EventResponseDto>> GetUpcomingEventsAsync()
        {
            var events = await _eventRepo.GetPagedAsync(e => e.EndDate >= System.DateTime.UtcNow, q => q.OrderBy(e => e.StartDate), 1, 10);
            return _mapper.Map<List<EventResponseDto>>(events);
        }

        public async Task<List<EventResponseDto>> GetPlaceEventsAsync(int placeId)
        {
            var events = await _eventRepo.GetSortedAsync(e => e.PlaceID == placeId, q => q.OrderByDescending(e => e.StartDate));
            return _mapper.Map<List<EventResponseDto>>(events);
        }

        public async Task<bool> UpdateEventAsync(int id, UpdateEventDto dto)
        {
            var e = await _eventRepo.GetByIdAsync(id);
            if (e == null) return false;

            if (dto.Name != null) e.Name = dto.Name;
            if (dto.StartDate.HasValue) e.StartDate = dto.StartDate.Value;
            if (dto.EndDate.HasValue) e.EndDate = dto.EndDate.Value;
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> DeleteEventAsync(int id)
        {
            var e = await _eventRepo.GetByIdAsync(id);
            if (e == null) return false;
            _eventRepo.Remove(e);
            await _unitOfWork.CommitAsync();
            return true;
        }
    }
}
