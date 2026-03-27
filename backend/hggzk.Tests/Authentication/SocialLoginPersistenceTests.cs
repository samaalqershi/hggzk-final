using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using YemenBooking.Core.Entities;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.Repositories.Users;

namespace YemenBooking.Tests.Authentication;

/// <summary>
/// Verifies that enriching a newly-created social user before the first save
/// does not break the pending insert / user-role relationship.
/// </summary>
public sealed class SocialLoginPersistenceTests : IAsyncLifetime
{
    private ServiceProvider _serviceProvider = null!;
    private YemenBookingDbContext _dbContext = null!;

    public async Task InitializeAsync()
    {
        var services = new ServiceCollection();
        services.AddDbContext<YemenBookingDbContext>(options =>
            options.UseNpgsql("Host=localhost;Database=YemenBookingDb;Username=postgres;Password=postgres"));

        _serviceProvider = services.BuildServiceProvider();
        _dbContext = _serviceProvider.GetRequiredService<YemenBookingDbContext>();
        await _dbContext.Database.MigrateAsync();
    }

    public async Task DisposeAsync()
    {
        if (_dbContext != null)
        {
            await _dbContext.DisposeAsync();
        }

        _serviceProvider?.Dispose();
    }

    [Fact]
    public async Task CreateThenUpdateBeforeFirstSave_ShouldStillInsertUserAndUserRole()
    {
        await using var transaction = await _dbContext.Database.BeginTransactionAsync();

        var userRepository = new UserRepository(_dbContext);
        var roleRepository = new RoleRepository(_dbContext);

        var clientRole = await _dbContext.Roles.FirstAsync(r => r.Name == "Client");
        var userId = Guid.NewGuid();
        var email = $"social-test-{Guid.NewGuid():N}@example.com";

        var user = new User
        {
            Id = userId,
            Name = "Social Test User",
            Email = email,
            Phone = string.Empty,
            Password = "hashed-password",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            IsActive = true,
            EmailConfirmed = true,
            IsEmailVerified = true,
            EmailVerifiedAt = DateTime.UtcNow,
            SettingsJson = "{}",
            FavoritesJson = "[]"
        };

        await userRepository.CreateUserAsync(user);

        user.SettingsJson = "{\"social\":{\"google\":{\"id\":\"provider-123\"}}}";
        user.UpdatedAt = DateTime.UtcNow;
        await userRepository.UpdateUserAsync(user);

        _dbContext.Entry(user).State.Should().Be(EntityState.Added);

        await roleRepository.AssignRoleToUserAsync(userId, clientRole.Id);
        await userRepository.SaveChangesAsync();

        var savedUser = await _dbContext.Users.IgnoreQueryFilters().FirstOrDefaultAsync(u => u.Id == userId);
        var savedUserRole = await _dbContext.UserRoles.IgnoreQueryFilters()
            .FirstOrDefaultAsync(ur => ur.UserId == userId && ur.RoleId == clientRole.Id);

        savedUser.Should().NotBeNull();
        savedUser!.SettingsJson.Should().Contain("provider-123");
        savedUserRole.Should().NotBeNull();

        await transaction.RollbackAsync();
    }
}
