import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/country_model.dart';

class CountryRepository {
  final ApiClient _api = ApiClient();

  Future<List<Country>> getAllCountries() async {
    final body = await _api.get('/countries');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Country> getCountryById(String id) async {
    final body = await _api.get('/countries/$id');
    return Country.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Country> getCountryByCode(String code) async {
    final body = await _api.get('/countries/code/$code');
    return Country.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Country> createCountry(CreateCountryRequest request) async {
    final body = await _api.post('/countries', data: request.toJson());
    return Country.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCountry(String id) async {
    await _api.delete('/countries/$id');
  }
}
