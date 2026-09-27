import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/view_models/navigation_view_model.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _horsepowerController = TextEditingController();
  final _mileageController = TextEditingController();
  final _usageHoursController = TextEditingController();
  final _consoleNameController = TextEditingController();
  final _gameNameController = TextEditingController();

  String? _selectedFamily;
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedCommune;

  String? _selectedFuel;
  String? _selectedCondition;
  String? _selectedItemType;
  String? _selectedConsole;

  String _pricingType = 'Prix fixe';

  final Map<String, List<String>> _categoriesParFamille = {
    'Véhicules': [
      'Voitures',
      'Camions',
      'Motos / Quads',
      'Vélos',
      'Pièces automobiles',
      'Pièces moto/quad',
    ],
    'Électronique': [
  'Ordinateurs',
  'Téléphone',
  'Accessoires téléphone',
  'Télévision',
  'Appareil photo / Caméra',
  'Hi-Fi',
  'Tablettes',
  'Consoles et jeux vidéo',
],
    'Instruments': [
      'Guitares',
      'Pianos / Claviers',
      'Batteries / Percussions',
      'Instruments à vent',
      'Autres instruments',
      'Accessoires instruments',
    ],
    'Électroménager': [
      'Électroménager',
    ],
    'Maison / Ndaku': [
      'Table',
      'Armoire',
      'Chaise',
      'Lit',
      'Matelas',
    ],
    'Matériel chantier': [
      'Machines',
      'Outillage',
    ],
    'Prestations de services': [
      'Bâtiment / Construction',
      'Mécanique automobile / moto',
      'Électricité',
      'Plomberie',
      'Menuiserie',
      'Peinture',
      'Informatique / Téléphonie',
      'Transport / Livraison',
      'Nettoyage',
      'Couture',
      'Coiffure / Beauté',
      'Événementiel',
      'Formation / Cours',
      'Autres services',
    ],
    'Autres': [
      'Autres',
    ],
  };

  final Map<String, List<String>> _communesParVille = {
    'Kinshasa': [
      'Bandalungwa',
      'Barumbu',
      'Bumbu',
      'Gombe',
      'Kalamu',
      'Kasa-Vubu',
      'Kimbanseke',
      'Kinshasa',
      'Kintambo',
      'Kisenso',
      'Lemba',
      'Limete',
      'Lingwala',
      'Makala',
      'Maluku',
      'Masina',
      'Matete',
      'Mont-Ngafula',
      'Ndjili',
      'Ngaba',
      'Ngaliema',
      'Ngiri-Ngiri',
      'Nsele',
      'Selembao',
    ],
  };

  final List<String> _conditions = [
    'Neuf',
    'Comme neuf',
    'Bon état',
    'État correct',
    'Pour pièces',
  ];

  final List<String> _fuels = [
    'Essence',
    'Gasoil',
  ];

  final List<String> _consoles = [
    'PlayStation 5',
    'PlayStation 4',
    'PlayStation 3',
    'Xbox Series X/S',
    'Xbox One',
    'Nintendo Switch',
    'Nintendo Wii',
    'PC',
    'Autre',
  ];

  bool get _isService =>
      _selectedFamily == 'Prestations de services';

  bool get _isVehicle =>
      _selectedCategory == 'Voitures' ||
      _selectedCategory == 'Camions' ||
      _selectedCategory == 'Motos / Quads';

  bool get _isFurniture =>
      _selectedCategory == 'Table' ||
      _selectedCategory == 'Armoire' ||
      _selectedCategory == 'Chaise' ||
      _selectedCategory == 'Lit' ||
      _selectedCategory == 'Matelas';

  bool get _isConsoleGames =>
      _selectedCategory == 'Consoles et jeux vidéo';

  bool get _isMachine =>
      _selectedCategory == 'Machines';

  bool get _isTool =>
      _selectedCategory == 'Outillage';

  bool get _isElectronicWithCondition {
  return _selectedCategory == 'Téléphone' ||
      _selectedCategory == 'Accessoires téléphone' ||
      _selectedCategory == 'Télévision' ||
      _selectedCategory == 'Appareil photo / Caméra' ||
      _selectedCategory == 'Hi-Fi' ||
      _selectedCategory == 'Tablettes';
}

  bool get _isInstrument =>
      _selectedFamily == 'Instruments';

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _horsepowerController.dispose();
    _mileageController.dispose();
    _usageHoursController.dispose();
    _consoleNameController.dispose();
    _gameNameController.dispose();
    super.dispose();
  }

  InputDecoration _decoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _space() => const SizedBox(height: 16);

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool number = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          number ? TextInputType.number : TextInputType.text,
      decoration: _decoration(
        label: label,
        hint: hint,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _conditionField() {
    return DropdownButtonFormField<String>(
      value: _selectedCondition,
      isExpanded: true,
      decoration: _decoration(
        label: 'État du bien',
      ),
      items: _conditions
          .map(
            (condition) => DropdownMenuItem(
              value: condition,
              child: Text(condition),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCondition = value;
        });
      },
    );
  }

  Widget _fuelField() {
    return DropdownButtonFormField<String>(
      value: _selectedFuel,
      isExpanded: true,
      decoration: _decoration(
        label: 'Carburant',
      ),
      items: _fuels
          .map(
            (fuel) => DropdownMenuItem(
              value: fuel,
              child: Text(fuel),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedFuel = value;
        });
      },
    );
  }

  Widget _servicePricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tarification',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: const Text('Prix fixe'),
          value: 'Prix fixe',
          groupValue: _pricingType,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _pricingType = value;
            });
          },
        ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sur devis'),
          value: 'Sur devis',
          groupValue: _pricingType,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _pricingType = value;
              _priceController.clear();
            });
          },
        ),
        if (_pricingType == 'Prix fixe') ...[
          const SizedBox(height: 8),
          _textField(
            controller: _priceController,
            label: 'Prix de la prestation',
            hint: 'Prix en FC',
            number: true,
          ),
        ],
      ],
    );
  }

  List<Widget> _specificFields() {
    if (_isVehicle) {
      return [
        _textField(
          controller: _brandController,
          label: 'Marque',
          hint: 'Ex : Toyota',
        ),
        _space(),
        _textField(
          controller: _modelController,
          label: 'Modèle',
        ),
        _space(),
        _textField(
          controller: _yearController,
          label: 'Année',
          number: true,
        ),
        _space(),
        _textField(
          controller: _horsepowerController,
          label: 'CV',
          number: true,
        ),
        _space(),
        _fuelField(),
        _space(),
        _textField(
          controller: _mileageController,
          label: 'Kilométrage',
          hint: 'Ex : 85000',
          number: true,
        ),
        _space(),
        _conditionField(),
      ];
    }

    if (_isFurniture) {
      return [
        _conditionField(),
      ];
    }

    if (_isConsoleGames) {
      return [
        DropdownButtonFormField<String>(
          value: _selectedItemType,
          decoration: _decoration(
            label: 'Type',
          ),
          items: const [
            DropdownMenuItem(
              value: 'Console',
              child: Text('Console'),
            ),
            DropdownMenuItem(
              value: 'Jeu',
              child: Text('Jeu vidéo'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedItemType = value;
            });
          },
        ),
        if (_selectedItemType == 'Console') ...[
          _space(),
          _textField(
            controller: _consoleNameController,
            label: 'Nom / marque',
            hint: 'Ex : PlayStation',
          ),
          _space(),
          _textField(
            controller: _modelController,
            label: 'Modèle',
            hint: 'Ex : PS5 Slim',
          ),
          _space(),
          _conditionField(),
        ],
        if (_selectedItemType == 'Jeu') ...[
          _space(),
          _textField(
            controller: _gameNameController,
            label: 'Nom du jeu',
          ),
          _space(),
          DropdownButtonFormField<String>(
            value: _selectedConsole,
            isExpanded: true,
            decoration: _decoration(
              label: 'Console compatible',
            ),
            items: _consoles
                .map(
                  (console) => DropdownMenuItem(
                    value: console,
                    child: Text(console),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedConsole = value;
              });
            },
          ),
          _space(),
          _conditionField(),
        ],
      ];
    }

    if (_isElectronicWithCondition) {
      return [
        _conditionField(),
      ];
    }

    if (_isInstrument) {
      return [
        _conditionField(),
      ];
    }

    if (_isMachine) {
      return [
        _textField(
          controller: _brandController,
          label: 'Marque',
        ),
        _space(),
        _textField(
          controller: _modelController,
          label: 'Modèle',
        ),
        _space(),
        _textField(
          controller: _yearController,
          label: 'Année',
          number: true,
        ),
        _space(),
        _fuelField(),
        _space(),
        _textField(
          controller: _usageHoursController,
          label: 'Heures d’utilisation',
          number: true,
        ),
        _space(),
        _conditionField(),
      ];
    }

    if (_isTool) {
      return [
        _textField(
          controller: _brandController,
          label: 'Marque',
        ),
        _space(),
        _textField(
          controller: _modelController,
          label: 'Modèle',
        ),
        _space(),
        _conditionField(),
      ];
    }

    return [];
  }

  void _resetSpecificFields() {
    _brandController.clear();
    _modelController.clear();
    _yearController.clear();
    _horsepowerController.clear();
    _mileageController.clear();
    _usageHoursController.clear();
    _consoleNameController.clear();
    _gameNameController.clear();

    _selectedFuel = null;
    _selectedCondition = null;
    _selectedItemType = null;
    _selectedConsole = null;
  }

  bool _validateSpecificFields() {
    if (_isVehicle) {
      if (_brandController.text.trim().isEmpty ||
          _modelController.text.trim().isEmpty) {
        _showMessage(
          'Veuillez renseigner la marque et le modèle.',
        );
        return false;
      }

      if (int.tryParse(_yearController.text.trim()) == null) {
        _showMessage(
          'Veuillez saisir une année valide.',
        );
        return false;
      }

      if (int.tryParse(
            _horsepowerController.text.trim(),
          ) ==
          null) {
        _showMessage(
          'Veuillez saisir le nombre de CV.',
        );
        return false;
      }

      if (_selectedFuel == null) {
        _showMessage(
          'Veuillez choisir le carburant.',
        );
        return false;
      }

      if (int.tryParse(
            _mileageController.text.trim(),
          ) ==
          null) {
        _showMessage(
          'Veuillez saisir le kilométrage.',
        );
        return false;
      }

      if (_selectedCondition == null) {
        _showMessage(
          'Veuillez choisir l’état du bien.',
        );
        return false;
      }
    }

    if (_isFurniture &&
        _selectedCondition == null) {
      _showMessage(
        'Veuillez renseigner l’état du meuble.',
      );
      return false;
    }

    if (_isConsoleGames) {
      if (_selectedItemType == null) {
        _showMessage(
          'Choisissez Console ou Jeu vidéo.',
        );
        return false;
      }

      if (_selectedItemType == 'Console' &&
          (_consoleNameController.text.trim().isEmpty ||
              _modelController.text.trim().isEmpty ||
              _selectedCondition == null)) {
        _showMessage(
          'Veuillez compléter les informations de la console.',
        );
        return false;
      }

      if (_selectedItemType == 'Jeu' &&
          (_gameNameController.text.trim().isEmpty ||
              _selectedConsole == null ||
              _selectedCondition == null)) {
        _showMessage(
          'Veuillez compléter les informations du jeu.',
        );
        return false;
      }
    }

    if (_isElectronicWithCondition &&
        _selectedCondition == null) {
      _showMessage(
        'Veuillez choisir l’état du bien.',
      );
      return false;
    }

    if (_isInstrument &&
        _selectedCondition == null) {
      _showMessage(
        'Veuillez choisir l’état de l’instrument.',
      );
      return false;
    }

    if (_isMachine) {
      if (_brandController.text.trim().isEmpty ||
          _modelController.text.trim().isEmpty ||
          int.tryParse(_yearController.text.trim()) == null ||
          _selectedFuel == null ||
          int.tryParse(
                _usageHoursController.text.trim(),
              ) ==
              null ||
          _selectedCondition == null) {
        _showMessage(
          'Veuillez compléter les informations de la machine.',
        );
        return false;
      }
    }

    if (_isTool &&
        (_brandController.text.trim().isEmpty ||
            _modelController.text.trim().isEmpty ||
            _selectedCondition == null)) {
      _showMessage(
        'Veuillez compléter les informations de l’outillage.',
      );
      return false;
    }

    return true;
  }

  void _continueToPhotos() {
    final title =
        _titleController.text.trim();

    final description =
        _descriptionController.text.trim();

    if (title.isEmpty) {
      _showMessage(
        'Veuillez saisir le titre de l’annonce.',
      );
      return;
    }

    if (_selectedFamily == null ||
        _selectedCategory == null) {
      _showMessage(
        'Veuillez choisir la famille et la sous-catégorie.',
      );
      return;
    }

    if (_isService) {
      if (_pricingType == 'Prix fixe' &&
          int.tryParse(
                _priceController.text.trim(),
              ) ==
              null) {
        _showMessage(
          'Veuillez saisir le prix de la prestation.',
        );
        return;
      }
    } else {
      if (int.tryParse(
            _priceController.text.trim(),
          ) ==
          null) {
        _showMessage(
          'Veuillez saisir un prix valide.',
        );
        return;
      }
    }

    if (!_validateSpecificFields()) {
      return;
    }

    if (_selectedCity == null ||
        _selectedCommune == null) {
      _showMessage(
        'Veuillez choisir la ville et la commune.',
      );
      return;
    }

    if (description.isEmpty) {
      _showMessage(
        'Veuillez ajouter une description.',
      );
      return;
    }

    final price =
        _isService &&
                _pricingType == 'Sur devis'
            ? '0'
            : _priceController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhotoScreen(
          title: title,
          price: price,
          city: _selectedCity!,
          district: _selectedCommune!,
          description: description,
          family: _selectedFamily!,
          category: _selectedCategory!,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          manufactureYear:
              int.tryParse(
            _yearController.text.trim(),
          ),
          horsepower:
              int.tryParse(
            _horsepowerController.text.trim(),
          ),
          fuelType:
              _selectedFuel ?? '',
          mileage:
              int.tryParse(
            _mileageController.text.trim(),
          ),
          itemCondition:
              _selectedCondition ?? '',
          itemType:
              _selectedItemType ?? '',
          compatibleConsole:
              _selectedConsole ?? '',
          usageHours:
              int.tryParse(
            _usageHoursController.text.trim(),
          ),
          consoleName:
              _consoleNameController.text.trim(),
          gameName:
              _gameNameController.text.trim(),
          pricingType:
              _isService
                  ? _pricingType
                  : 'Prix fixe',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _selectedFamily == null
            ? <String>[]
            : _categoriesParFamille[
                    _selectedFamily] ??
                [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Déposer une annonce',
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Que voulez-vous proposer ?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // ==================================================
          // TITRE
          // ==================================================

          _textField(
            controller: _titleController,
            label: 'Titre de l’annonce',
            hint: 'Ex : iPhone 13, Toyota Corolla, Canapé...',
          ),

          _space(),

          // ==================================================
          // FAMILLE
          // ==================================================

          DropdownButtonFormField<String>(
            value: _selectedFamily,
            isExpanded: true,
            decoration: _decoration(
              label: 'Famille',
            ),
            items: _categoriesParFamille.keys
                .map(
                  (family) =>
                      DropdownMenuItem(
                    value: family,
                    child: Text(family),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFamily = value;
                _selectedCategory = null;
                _pricingType = 'Prix fixe';

                // Le prix n'est volontairement PAS effacé.
                _resetSpecificFields();
              });
            },
          ),

          _space(),

          // ==================================================
          // SOUS-CATÉGORIE
          // ==================================================

          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration: _decoration(
              label: 'Sous-catégorie',
            ),
            items: categories
                .map(
                  (category) =>
                      DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            onChanged:
                _selectedFamily == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategory =
                              value;
                          _resetSpecificFields();
                        });
                      },
          ),

          if (_isService) ...[
            _space(),
            _servicePricing(),
          ],

          if (_specificFields().isNotEmpty) ...[
            _space(),
            ..._specificFields(),
          ],

          _space(),

          // ==================================================
          // VILLE
          // ==================================================

          DropdownButtonFormField<String>(
            value: _selectedCity,
            isExpanded: true,
            decoration: _decoration(
              label: 'Ville',
            ),
            items: _communesParVille.keys
                .map(
                  (city) =>
                      DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedCommune = null;
              });
            },
          ),

          _space(),

          // ==================================================
          // COMMUNE
          // ==================================================

          DropdownButtonFormField<String>(
            value: _selectedCommune,
            isExpanded: true,
            decoration: _decoration(
              label: 'Commune',
            ),
            items: _selectedCity == null
                ? []
                : (_communesParVille[
                            _selectedCity] ??
                        [])
                    .map(
                      (commune) =>
                          DropdownMenuItem(
                        value: commune,
                        child: Text(commune),
                      ),
                    )
                    .toList(),
            onChanged:
                _selectedCity == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCommune =
                              value;
                        });
                      },
          ),

          _space(),

          // ==================================================
          // PRIX JUSTE AVANT DESCRIPTION
          // ==================================================

          if (!_isService) ...[
            _textField(
              controller: _priceController,
              label: 'Prix',
              hint: 'Prix en FC',
              number: true,
            ),
            _space(),
          ],

          // ==================================================
          // DESCRIPTION
          // ==================================================

          TextField(
            controller:
                _descriptionController,
            maxLines: 5,
            decoration: _decoration(
              label: _isService
                  ? 'Description de la prestation'
                  : 'Description',
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed:
                  _continueToPhotos,
              icon: const Icon(
                Icons.arrow_forward,
              ),
              label: const Text(
                'Continuer',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// PHOTO
// ==========================================================

class AddPhotoScreen extends StatefulWidget {
  final String title;
  final String price;
  final String city;
  final String district;
  final String description;
  final String family;
  final String category;

  final String brand;
  final String model;
  final int? manufactureYear;
  final int? horsepower;
  final String fuelType;
  final int? mileage;
  final String itemCondition;
  final String itemType;
  final String compatibleConsole;
  final int? usageHours;
  final String consoleName;
  final String gameName;
  final String pricingType;

  const AddPhotoScreen({
    super.key,
    required this.title,
    required this.price,
    required this.city,
    required this.district,
    required this.description,
    required this.family,
    required this.category,
    required this.brand,
    required this.model,
    required this.manufactureYear,
    required this.horsepower,
    required this.fuelType,
    required this.mileage,
    required this.itemCondition,
    required this.itemType,
    required this.compatibleConsole,
    required this.usageHours,
    required this.consoleName,
    required this.gameName,
    required this.pricingType,
  });

  @override
  State
