// lib/app/modules/country/controllers/country_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/country_repository.dart';
import '../../../data/models/country_model.dart';

class CountryController extends GetxController {
  final CountryRepository _countryRepository = CountryRepository();
  
  var countries = <Country>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var selectedCountry = Rxn<Country>();

  @override
  void onInit() {
    super.onInit();
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final fetchedCountries = await _countryRepository.getAllCountries();
      countries.value = fetchedCountries;
      
      // Sort alphabetically by name
      countries.sort((a, b) => a.name.compareTo(b.name));
      
      print('Loaded ${countries.length} countries');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading countries: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedCountry(Country? country) {
    selectedCountry.value = country;
  }

  void clearSelectedCountry() {
    selectedCountry.value = null;
  }

  Future<void> refreshCountries() async {
    await loadCountries();
  }
}