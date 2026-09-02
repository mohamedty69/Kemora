using System.Threading;
using System.Threading.Tasks;
using Kemora.Application.DTOs;

namespace Kemora.Application.Interfaces
{
    public interface IPlacesSyncService
    {
        Task<SyncResultDto> SyncGovernorateAsync(int governorateId, CancellationToken ct = default);
        Task<SyncResultDto> TestSyncPortSaidAsync(CancellationToken ct = default);
    }
}
