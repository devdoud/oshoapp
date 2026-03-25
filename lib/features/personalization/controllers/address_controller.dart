import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/addresses/address_repository.dart';
import 'package:osho/features/personalization/models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final isLoading = false.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddress = Rx<AddressModel?>(null);
  final _addressRepository = Get.put(AddressRepository());

  @override
  void onInit() {
    super.onInit();
    fetchUserAddresses();
  }

  Future<void> fetchUserAddresses() async {
    try {
      isLoading.value = true;
      final list = await _addressRepository.fetchUserAddresses();
      addresses.assignAll(list);
      _selectDefault(list);
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAddress(AddressModel address,
      {bool setDefault = false}) async {
    try {
      isLoading.value = true;
      final created = await _addressRepository.createAddress(address);
      addresses.add(created);

      if (setDefault || addresses.length == 1) {
        await setDefaultAddress(created, showMessage: false);
      } else if (selectedAddress.value == null) {
        selectedAddress.value = created;
      }

      OLoaders.successSnackBar(
          title: 'Succes', message: 'Adresse enregistree.');
      return true;
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultAddress(AddressModel address,
      {bool showMessage = true}) async {
    if (address.id == null) return;

    try {
      isLoading.value = true;
      await _addressRepository.setDefaultAddress(address.id!);

      final updated = addresses
          .map((item) => item.copyWith(isDefault: item.id == address.id))
          .toList();
      addresses.assignAll(updated);
      selectedAddress.value = address.copyWith(isDefault: true);

      if (showMessage) {
        OLoaders.successSnackBar(
            title: 'Adresse principale', message: 'Adresse mise a jour.');
      }
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectAddress(AddressModel address,
      {bool makeDefault = false}) async {
    selectedAddress.value = address;
    if (makeDefault) {
      await setDefaultAddress(address);
    }
  }

  void _selectDefault(List<AddressModel> list) {
    if (list.isEmpty) {
      selectedAddress.value = null;
      return;
    }

    final defaultAddress =
        list.firstWhereOrNull((address) => address.isDefault);
    selectedAddress.value = defaultAddress ?? list.first;
  }
}
