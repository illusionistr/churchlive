import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../core/network/supabase_client.dart';
import '../../domain/entities/church.dart';
import '../models/church_model.dart';

/// Repository for handling church data operations
class ChurchRepository {
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  final Logger _logger = GetIt.instance<Logger>();

  /// Map denomination ID strings to database names
  String _mapDenominationIdToName(String denominationId) {
    switch (denominationId.toLowerCase()) {
      case 'catholic':
        return 'Catholic';
      case 'baptist':
        return 'Baptist';
      case 'methodist':
        return 'Methodist';
      case 'presbyterian':
        return 'Presbyterian';
      case 'lutheran':
        return 'Lutheran';
      case 'pentecostal':
        return 'Pentecostal';
      case 'anglican':
        return 'Anglican/Episcopal';
      case 'orthodox':
        return 'Orthodox';
      case 'non_denominational':
        return 'Non-denominational';
      case 'evangelical':
        return 'Evangelical';
      case 'assemblies_of_god':
        return 'Assemblies of God';
      case 'seventh_day_adventist':
        return 'Seventh-day Adventist';
      default:
        return denominationId; // fallback to original if not found
    }
  }

  /// Fetch all churches with optional filtering
  Future<List<Church>> getChurches({
    String? denominationFilter,
    String? countryFilter,
    String? languageFilter,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _logger.i(
        'Fetching churches with filters: denomination=$denominationFilter, country=$countryFilter',
      );

      var queryBuilder = _supabaseService.database
          .from('churches')
          .select('''
             *,
             denominations!inner(id, name),
             countries!inner(id, name, code),
             languages!churches_primary_language_id_fkey(id, name, code)
           ''')
          .eq('is_active', true);

      // Apply denomination filter
      if (denominationFilter != null && denominationFilter.isNotEmpty) {
        // Map string denomination to proper name for filtering
        String denominationName = _mapDenominationIdToName(denominationFilter);
        queryBuilder = queryBuilder.eq('denominations.name', denominationName);
      }

      // Apply country filter
      if (countryFilter != null && countryFilter.isNotEmpty) {
        queryBuilder = queryBuilder.eq('country_id', countryFilter);
      }

      // Apply language filter
      if (languageFilter != null && languageFilter.isNotEmpty) {
        queryBuilder = queryBuilder.eq('primary_language_id', languageFilter);
      }

      final response = await queryBuilder
          .order('member_count', ascending: false)
          .range(offset, offset + limit - 1);

      _logger.i('Successfully fetched ${response.length} churches');

      return response.map<Church>((json) {
        try {
          return ChurchModel.fromJson(json).toEntity();
        } catch (e) {
          _logger.w('Error parsing church data: $e');
          // Return a fallback church object or skip this record
          return Church(
            id: json['id'] ?? 'unknown',
            name: json['name'] ?? 'Unknown Church',
            denominationId: json['denomination_id'],
            countryId: json['country_id'],
            primaryLanguageId: json['primary_language_id'],
            timezone: json['timezone'] ?? 'UTC',
            verificationStatus: ChurchVerificationStatus.unverified,
            isActive: json['is_active'] ?? true,
            memberCount: json['member_count'] ?? 0,
            memberCountRange: json['member_count_range'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            averageRating: 0.0,
            reviewCount: 0,
            liveStreamsCount: 0,
            followersCount: 0,
          );
        }
      }).toList();
    } catch (e) {
      _logger.e('Error fetching churches: $e');
      rethrow;
    }
  }

  /// Fetch churches by denomination
  Future<List<Church>> getChurchesByDenomination(String denominationId) async {
    return getChurches(denominationFilter: denominationId);
  }

  /// Fetch only churches that are currently live
  Future<List<Church>> getLiveChurches({
    String? denominationFilter,
    int limit = 20,
  }) async {
    try {
      _logger.i(
        'Fetching live churches with denomination filter: $denominationFilter',
      );

      // Simply query churches that are currently live
      var queryBuilder = _supabaseService.database
          .from('churches')
          .select('''
             *,
             denominations!inner(id, name),
             countries!inner(id, name, code),
             languages!churches_primary_language_id_fkey(id, name, code)
           ''')
          .eq('is_active', true)
          .eq('is_live', true);

      // Apply denomination filter
      if (denominationFilter != null && denominationFilter.isNotEmpty) {
        String denominationName = _mapDenominationIdToName(denominationFilter);
        queryBuilder = queryBuilder.eq('denominations.name', denominationName);
      }

      final response = await queryBuilder
          .order('last_live_check', ascending: false)
          .limit(limit);

      _logger.i('Successfully fetched ${response.length} live churches');

      return response.map<Church>((json) {
        try {
          return ChurchModel.fromJson(json).toEntity();
        } catch (e) {
          _logger.w('Error parsing live church data: $e');
          _logger.d('Raw JSON: $json');
          // Return a fallback church object
          return Church(
            id: json['id'] ?? 'unknown',
            name: json['name'] ?? 'Unknown Church',
            denominationId: json['denomination_id'],
            countryId: json['country_id'],
            primaryLanguageId: json['primary_language_id'],
            timezone: json['timezone'] ?? 'UTC',
            verificationStatus: ChurchVerificationStatus.unverified,
            isActive: json['is_active'] ?? true,
            memberCount: json['member_count'] ?? 0,
            memberCountRange: json['member_count_range'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            averageRating: 0.0,
            reviewCount: 0,
            liveStreamsCount: 0,
            followersCount: 0,
            isCurrentlyLive: true, // We know it's live from the query
          );
        }
      }).toList();
    } catch (e) {
      _logger.e('Error fetching live churches: $e');
      // Return empty list instead of rethrowing to prevent UI crashes
      return [];
    }
  }

  /// Search churches by name or description
  Future<List<Church>> searchChurches(String query) async {
    try {
      _logger.i('Searching churches with query: $query');

      final response = await _supabaseService.database
          .from('churches')
          .select('''
             *,
             denominations!inner(id, name),
             countries!inner(id, name, code),
             languages!churches_primary_language_id_fkey(id, name, code)
           ''')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_active', true)
          .order('member_count', ascending: false)
          .limit(20);

      _logger.i('Found ${response.length} churches matching query');

      return response.map<Church>((json) {
        try {
          return ChurchModel.fromJson(json).toEntity();
        } catch (e) {
          _logger.w('Error parsing search result: $e');
          return Church(
            id: json['id'] ?? 'unknown',
            name: json['name'] ?? 'Unknown Church',
            denominationId: json['denomination_id'],
            countryId: json['country_id'],
            primaryLanguageId: json['primary_language_id'],
            timezone: json['timezone'] ?? 'UTC',
            verificationStatus: ChurchVerificationStatus.unverified,
            isActive: json['is_active'] ?? true,
            memberCount: json['member_count'] ?? 0,
            memberCountRange: json['member_count_range'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            averageRating: 0.0,
            reviewCount: 0,
            liveStreamsCount: 0,
            followersCount: 0,
          );
        }
      }).toList();
    } catch (e) {
      _logger.e('Error searching churches: $e');
      rethrow;
    }
  }

  /// Get featured churches (highly rated or popular)
  Future<List<Church>> getFeaturedChurches() async {
    try {
      _logger.i('Fetching featured churches');

      final response = await _supabaseService.database
          .from('churches')
          .select('''
             *,
             denominations!inner(id, name),
             countries!inner(id, name, code),
             languages!churches_primary_language_id_fkey(id, name, code)
           ''')
          .eq('is_active', true)
          .eq('verification_status', 'verified')
          .gte('member_count', 1000) // Churches with 1000+ members
          .order('member_count', ascending: false)
          .limit(10);

      _logger.i('Fetched ${response.length} featured churches');

      return response
          .map<Church>((json) => ChurchModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.e('Error fetching featured churches: $e');
      rethrow;
    }
  }

  /// Get church details by ID
  Future<Church?> getChurchById(String churchId) async {
    try {
      _logger.i('Fetching church details for ID: $churchId');

      final response = await _supabaseService.database
          .from('churches')
          .select('''
             *,
             denominations!inner(id, name),
             countries!inner(id, name, code),
             languages!churches_primary_language_id_fkey(id, name, code)
           ''')
          .eq('id', churchId)
          .single();

      _logger.i('Successfully fetched church details');

      return ChurchModel.fromJson(response).toEntity();
    } catch (e) {
      _logger.e('Error fetching church by ID: $e');
      return null;
    }
  }

  /// Get churches near a location
  Future<List<Church>> getChurchesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int limit = 20,
  }) async {
    try {
      _logger.i('Fetching churches near location: $latitude, $longitude');

      // Use PostGIS functions for geospatial queries
      final response = await _supabaseService.database.rpc(
        'get_churches_near_location',
        params: {
          'user_lat': latitude,
          'user_lng': longitude,
          'radius_km': radiusKm,
          'result_limit': limit,
        },
      );

      _logger.i('Found ${response.length} churches near location');

      return response
          .map<Church>((json) => ChurchModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.w('Geospatial query failed, falling back to simple query: $e');
      // Fallback to simple query without location filtering
      return getChurches(limit: limit);
    }
  }
}
