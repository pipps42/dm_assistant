// lib/shared/repositories/base_repository.dart
import 'package:isar/isar.dart';

abstract class BaseRepository<T> {
  final Isar isar;
  
  BaseRepository(this.isar);
  
  /// Get the collection for this entity type
  IsarCollection<T> get collection;
  
  /// Get all entities
  Future<List<T>> getAll() async {
    return await collection.where().findAll();
  }
  
  /// Get entity by ID
  Future<T?> getById(Id id) async {
    return await collection.get(id);
  }
  
  /// Get entities by IDs
  Future<List<T?>> getByIds(List<Id> ids) async {
    return await collection.getAll(ids);
  }
  
  /// Save entity (create or update)
  Future<T> save(T entity) async {
    await isar.writeTxn(() async {
      await collection.put(entity);
    });
    return entity;
  }
  
  /// Save multiple entities
  Future<List<T>> saveAll(List<T> entities) async {
    await isar.writeTxn(() async {
      await collection.putAll(entities);
    });
    return entities;
  }
  
  /// Delete entity by ID
  Future<bool> deleteById(Id id) async {
    late bool deleted;
    await isar.writeTxn(() async {
      deleted = await collection.delete(id);
    });
    return deleted;
  }
  
  /// Delete multiple entities by IDs
  Future<int> deleteByIds(List<Id> ids) async {
    late int deletedCount;
    await isar.writeTxn(() async {
      deletedCount = await collection.deleteAll(ids);
    });
    return deletedCount;
  }
  
  /// Delete entity
  Future<bool> delete(T entity) async {
    final id = getId(entity);
    if (id == null) return false;
    return await deleteById(id);
  }
  
  /// Delete all entities
  Future<void> deleteAll() async {
    await isar.writeTxn(() async {
      await collection.clear();
    });
  }
  
  /// Count all entities
  Future<int> count() async {
    return await collection.count();
  }
  
  /// Check if entity exists by ID
  Future<bool> exists(Id id) async {
    return await collection.get(id) != null;
  }
  
  /// Get first entity matching query
  Future<T?> findFirst() async {
    return await collection.where().findFirst();
  }
  
  /// Get entities with pagination
  Future<List<T>> getWithPagination({
    int offset = 0,
    int limit = 20,
  }) async {
    return await collection
        .where()
        .offset(offset)
        .limit(limit)
        .findAll();
  }
  
  /// Get entities sorted by a field
  Future<List<T>> getAllSorted({
    bool ascending = true,
  }) async {
    final query = collection.where();
    return ascending 
        ? await query.findAll()
        : await query.findAll();
  }
  
  /// Search entities (to be implemented by subclasses)
  Future<List<T>> search(String query) async {
    // Default implementation returns all
    return await getAll();
  }
  
  /// Filter entities (to be implemented by subclasses)
  Future<List<T>> filter(Map<String, dynamic> filters) async {
    // Default implementation returns all
    return await getAll();
  }
  
  /// Get ID from entity (to be implemented by subclasses)
  Id? getId(T entity);
  
  /// Watch all entities (stream)
  Stream<List<T>> watchAll() {
    return collection.where().watch(fireImmediately: true);
  }
  
  /// Watch entity by ID (stream)
  Stream<T?> watchById(Id id) {
    return collection.watchObject(id, fireImmediately: true);
  }
  
  /// Watch entities with query (stream)
  Stream<List<T>> watchQuery(QueryBuilder<T, T, QWhere> Function(QueryBuilder<T, T, QWhere>) buildQuery) {
    return buildQuery(collection.where()).watch(fireImmediately: true);
  }
}

// Specialized repository for entities with common D&D fields
abstract class DnDEntityRepository<T> extends BaseRepository<T> {
  DnDEntityRepository(super.isar);
  
  /// Search by name (common for D&D entities)
  Future<List<T>> searchByName(String name) async {
    // To be implemented by subclasses with name-specific logic
    return await search(name);
  }
  
  /// Get entities created after a date
  Future<List<T>> getCreatedAfter(DateTime date) async {
    // To be implemented by subclasses with date-specific logic
    return await getAll();
  }
  
  /// Get entities updated after a date
  Future<List<T>> getUpdatedAfter(DateTime date) async {
    // To be implemented by subclasses with date-specific logic
    return await getAll();
  }
  
  /// Get recently created entities
  Future<List<T>> getRecent({int limit = 10}) async {
    return await getWithPagination(limit: limit);
  }
  
  /// Get favorite entities (if applicable)
  Future<List<T>> getFavorites() async {
    // To be implemented by subclasses with favorite-specific logic
    return await getAll();
  }
}

// Repository interface for entities that can be archived
mixin ArchivableRepository<T> on BaseRepository<T> {
  /// Get active (non-archived) entities
  Future<List<T>> getActive();
  
  /// Get archived entities
  Future<List<T>> getArchived();
  
  /// Archive entity
  Future<T> archive(T entity);
  
  /// Unarchive entity
  Future<T> unarchive(T entity);
}

// Repository interface for entities that can be favorited
mixin FavoritableRepository<T> on BaseRepository<T> {
  /// Get favorite entities
  Future<List<T>> getFavorites();
  
  /// Add to favorites
  Future<T> addToFavorites(T entity);
  
  /// Remove from favorites
  Future<T> removeFromFavorites(T entity);
  
  /// Toggle favorite status
  Future<T> toggleFavorite(T entity);
}

// Repository interface for entities with tags
mixin TaggableRepository<T> on BaseRepository<T> {
  /// Get entities by tag
  Future<List<T>> getByTag(String tag);
  
  /// Get entities by tags (any match)
  Future<List<T>> getByTags(List<String> tags);
  
  /// Get entities by tags (all match)
  Future<List<T>> getByAllTags(List<String> tags);
  
  /// Get all unique tags
  Future<List<String>> getAllTags();
  
  /// Add tag to entity
  Future<T> addTag(T entity, String tag);
  
  /// Remove tag from entity
  Future<T> removeTag(T entity, String tag);
}

// Repository interface for entities that belong to a campaign
mixin CampaignScopedRepository<T> on BaseRepository<T> {
  /// Get entities for a specific campaign
  Future<List<T>> getByCampaign(Id campaignId);
  
  /// Get entities for multiple campaigns
  Future<List<T>> getByCampaigns(List<Id> campaignIds);
  
  /// Move entity to different campaign
  Future<T> moveToCampaign(T entity, Id campaignId);
}

// Example repository exceptions
class RepositoryException implements Exception {
  final String message;
  final Exception? cause;
  
  const RepositoryException(this.message, [this.cause]);
  
  @override
  String toString() => 'RepositoryException: $message';
}

class EntityNotFoundException extends RepositoryException {
  const EntityNotFoundException(String entityType, dynamic id)
      : super('$entityType with id $id not found');
}

class EntityAlreadyExistsException extends RepositoryException {
  const EntityAlreadyExistsException(String entityType, dynamic id)
      : super('$entityType with id $id already exists');
}

class ValidationException extends RepositoryException {
  final Map<String, String> errors;
  
  const ValidationException(this.errors)
      : super('Validation failed');
}