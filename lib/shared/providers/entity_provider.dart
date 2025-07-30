// lib/shared/providers/entity_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/shared/repositories/base_repository.dart';

// Generic entity provider for CRUD operations
class EntityProvider<T> extends StateNotifier<AsyncValue<List<T>>> {
  final BaseRepository<T> _repository;

  EntityProvider(this._repository) : super(const AsyncValue.loading()) {
    _loadAll();
  }

  // Load all entities
  Future<void> _loadAll() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadAll();
  }

  // Get entity by ID
  Future<T?> getById(Id id) async {
    return await _repository.getById(id);
  }

  // Create entity
  Future<void> create(T entity) async {
    try {
      final savedEntity = await _repository.save(entity);
      state = state.whenData((entities) => [...entities, savedEntity]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Update entity
  Future<void> update(T entity) async {
    try {
      final updatedEntity = await _repository.save(entity);
      final entityId = _repository.getId(updatedEntity);

      state = state.whenData((entities) {
        final index = entities.indexWhere(
          (e) => _repository.getId(e) == entityId,
        );
        if (index != -1) {
          final newEntities = [...entities];
          newEntities[index] = updatedEntity;
          return newEntities;
        }
        return entities;
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Delete entity by ID
  Future<void> deleteById(Id id) async {
    try {
      final deleted = await _repository.deleteById(id);
      if (deleted) {
        state = state.whenData(
          (entities) =>
              entities.where((e) => _repository.getId(e) != id).toList(),
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Delete entity
  Future<void> delete(T entity) async {
    final id = _repository.getId(entity);
    if (id != null) {
      await deleteById(id);
    }
  }

  // Search entities
  Future<List<T>> search(String query) async {
    return await _repository.search(query);
  }

  // Filter entities
  Future<List<T>> filter(Map<String, dynamic> filters) async {
    return await _repository.filter(filters);
  }

  // Get with pagination
  Future<List<T>> getWithPagination({int offset = 0, int limit = 20}) async {
    return await _repository.getWithPagination(offset: offset, limit: limit);
  }

  // Save multiple entities
  Future<void> saveAll(List<T> entities) async {
    try {
      final savedEntities = await _repository.saveAll(entities);
      state = state.whenData((currentEntities) {
        final newEntities = [...currentEntities];
        for (final saved in savedEntities) {
          final id = _repository.getId(saved);
          final index = newEntities.indexWhere(
            (e) => _repository.getId(e) == id,
          );
          if (index != -1) {
            newEntities[index] = saved;
          } else {
            newEntities.add(saved);
          }
        }
        return newEntities;
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Delete multiple entities
  Future<void> deleteMultiple(List<Id> ids) async {
    try {
      await _repository.deleteByIds(ids);
      state = state.whenData(
        (entities) =>
            entities.where((e) => !ids.contains(_repository.getId(e))).toList(),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Single entity provider (for viewing/editing a specific entity)
class SingleEntityProvider<T> extends StateNotifier<AsyncValue<T?>> {
  final BaseRepository<T> _repository;
  final Id _entityId;

  SingleEntityProvider(this._repository, this._entityId)
    : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getById(_entityId));
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> update(T entity) async {
    try {
      final updated = await _repository.save(entity);
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete() async {
    try {
      await _repository.deleteById(_entityId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Notifier for CRUD operations (alternative to StateNotifier)
class EntityNotifier<T> extends StateNotifier<AsyncValue<void>> {
  final BaseRepository<T> _repository;
  final Ref _ref;
  final ProviderBase<AsyncValue<List<T>>> _listProvider;

  EntityNotifier(this._repository, this._ref, this._listProvider)
    : super(const AsyncValue.data(null));

  // Protected getters for subclasses
  BaseRepository<T> get repository => _repository;
  Ref get ref => _ref;
  ProviderBase<AsyncValue<List<T>>> get listProvider => _listProvider;

  Future<void> create(T entity) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.save(entity);
      _ref.invalidate(_listProvider);
    });
  }

  Future<void> update(T entity) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.save(entity);
      _ref.invalidate(_listProvider);
    });
  }

  Future<void> deleteById(Id id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteById(id);
      _ref.invalidate(_listProvider);
    });
  }

  Future<void> delete(T entity) async {
    final id = _repository.getId(entity);
    if (id != null) {
      await deleteById(id);
    }
  }
}

// Provider factory for creating entity providers
class EntityProviderFactory {
  // Create list provider
  static StateNotifierProvider<EntityProvider<T>, AsyncValue<List<T>>>
  createListProvider<T>(BaseRepository<T> repository) {
    return StateNotifierProvider<EntityProvider<T>, AsyncValue<List<T>>>(
      (ref) => EntityProvider<T>(repository),
    );
  }

  // Create single entity provider
  static StateNotifierProvider<SingleEntityProvider<T>, AsyncValue<T?>>
  createSingleProvider<T>(BaseRepository<T> repository, Id entityId) {
    return StateNotifierProvider<SingleEntityProvider<T>, AsyncValue<T?>>(
      (ref) => SingleEntityProvider<T>(repository, entityId),
    );
  }

  // Create CRUD notifier provider
  static StateNotifierProvider<EntityNotifier<T>, AsyncValue<void>>
  createNotifierProvider<T>(
    BaseRepository<T> repository,
    ProviderBase<AsyncValue<List<T>>> listProvider,
  ) {
    return StateNotifierProvider<EntityNotifier<T>, AsyncValue<void>>(
      (ref) => EntityNotifier<T>(repository, ref, listProvider),
    );
  }

  // Create future provider for single entity
  static FutureProviderFamily<T?, Id> createFutureProvider<T>(
    BaseRepository<T> repository,
  ) {
    return FutureProvider.family<T?, Id>((ref, id) => repository.getById(id));
  }

  // Create stream provider for watching all entities
  static StreamProvider<List<T>> createStreamProvider<T>(
    BaseRepository<T> repository,
  ) {
    return StreamProvider<List<T>>((ref) => repository.watchAll());
  }

  // Create stream provider for watching single entity
  static StreamProviderFamily<T?, Id> createSingleStreamProvider<T>(
    BaseRepository<T> repository,
  ) {
    return StreamProvider.family<T?, Id>((ref, id) => repository.watchById(id));
  }
}

// Specialized providers for D&D entities
abstract class DnDEntityProvider<T> extends EntityProvider<T> {
  DnDEntityProvider(super.repository);

  // Protected getter for repository access
  BaseRepository<T> get repository => _repository;

  // Search by name
  Future<List<T>> searchByName(String name) async {
    if (_repository is DnDEntityRepository<T>) {
      return await (_repository).searchByName(name);
    }
    return await search(name);
  }

  // Get recent entities
  Future<List<T>> getRecent({int limit = 10}) async {
    if (_repository is DnDEntityRepository<T>) {
      return await (_repository).getRecent(limit: limit);
    }
    return await getWithPagination(limit: limit);
  }

  // Get favorites (if repository supports it)
  Future<List<T>> getFavorites() async {
    if (_repository is FavoritableRepository<T>) {
      return await (_repository).getFavorites();
    }
    return await _repository.getAll();
  }
}

// Provider for archivable entities
mixin ArchivableEntityProvider<T> on EntityProvider<T> {
  Future<List<T>> getActive() async {
    if (_repository is ArchivableRepository<T>) {
      return await (_repository).getActive();
    }
    return await _repository.getAll();
  }

  Future<List<T>> getArchived() async {
    if (_repository is ArchivableRepository<T>) {
      return await (_repository).getArchived();
    }
    return [];
  }

  Future<void> archive(T entity) async {
    if (_repository is ArchivableRepository<T>) {
      try {
        await (_repository).archive(entity);
        await refresh();
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> unarchive(T entity) async {
    if (_repository is ArchivableRepository<T>) {
      try {
        await (_repository).unarchive(entity);
        await refresh();
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

// Provider for taggable entities
mixin TaggableEntityProvider<T> on EntityProvider<T> {
  Future<List<T>> getByTag(String tag) async {
    if (_repository is TaggableRepository<T>) {
      return await (_repository).getByTag(tag);
    }
    return [];
  }

  Future<List<String>> getAllTags() async {
    if (_repository is TaggableRepository<T>) {
      return await (_repository).getAllTags();
    }
    return [];
  }

  Future<void> addTag(T entity, String tag) async {
    if (_repository is TaggableRepository<T>) {
      try {
        await (_repository).addTag(entity, tag);
        await refresh();
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

// Helper class for creating common provider combinations
class EntityProviders<T> {
  late final StateNotifierProvider<EntityProvider<T>, AsyncValue<List<T>>> list;
  late final StateNotifierProvider<EntityNotifier<T>, AsyncValue<void>>
  notifier;
  late final FutureProviderFamily<T?, Id> single;
  late final StreamProvider<List<T>> stream;

  EntityProviders(BaseRepository<T> repository) {
    list = EntityProviderFactory.createListProvider(repository);
    notifier = EntityProviderFactory.createNotifierProvider(repository, list);
    single = EntityProviderFactory.createFutureProvider(repository);
    stream = EntityProviderFactory.createStreamProvider(repository);
  }
}
