import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/models/annonce.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';

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
      'Photo / Audio / Caméra',
      'Consoles et jeux vidéo',
    ],
    'Électroménager': [
      'Électroménager',
    ],
    'Maison / Ndaku': [
      'Meubles',
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
    'Bon état',
    'Moyen',
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
      _selectedCategory == 'Meubles';

  bool get _isConsoleGames =>
      _selectedCategory == 'Consoles et jeux vidéo';

  bool get _isMachine =>
      _selectedCategory == 'Machines';

  bool get _isTool =>
      _selectedCategory == 'Outillage';

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
        DropdownButtonFormField<String>(
          value: _selectedItemType,
          decoration: _decoration(
            label: 'Type de meuble',
          ),
          items: const [
            DropdownMenuItem(
              value: 'Table',
              child: Text('Table'),
            ),
            DropdownMenuItem(
              value: 'Armoire',
              child: Text('Armoire'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedItemType = value;
            });
          },
        ),
        _space(),
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
        _showMessage('Veuillez saisir une année valide.');
        return false;
      }

      if (int.tryParse(
            _horsepowerController.text.trim(),
          ) ==
          null) {
        _showMessage('Veuillez saisir le nombre de CV.');
        return false;
      }

      if (_selectedFuel == null) {
        _showMessage('Veuillez choisir le carburant.');
        return false;
      }

      if (int.tryParse(
            _mileageController.text.trim(),
          ) ==
          null) {
        _showMessage('Veuillez saisir le kilométrage.');
        return false;
      }

      if (_selectedCondition == null) {
        _showMessage('Veuillez choisir l’état du bien.');
        return false;
      }
    }

    if (_isFurniture &&
        (_selectedItemType == null ||
            _selectedCondition == null)) {
      _showMessage(
        'Veuillez renseigner le type de meuble et son état.',
      );
      return false;
    }

    if (_isConsoleGames) {
      if (_selectedItemType == null) {
        _showMessage('Choisissez Console ou Jeu vidéo.');
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
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showMessage('Veuillez saisir le titre de l’annonce.');
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
          int.tryParse(_priceController.text.trim()) == null) {
        _showMessage(
          'Veuillez saisir le prix de la prestation.',
        );
        return;
      }
    } else {
      if (int.tryParse(_priceController.text.trim()) == null) {
        _showMessage('Veuillez saisir un prix valide.');
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
      _showMessage('Veuillez ajouter une description.');
      return;
    }

    final price = _isService && _pricingType == 'Sur devis'
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
              int.tryParse(_yearController.text.trim()),
          horsepower:
              int.tryParse(_horsepowerController.text.trim()),
          fuelType: _selectedFuel ?? '',
          mileage:
              int.tryParse(_mileageController.text.trim()),
          itemCondition: _selectedCondition ?? '',
          itemType: _selectedItemType ?? '',
          compatibleConsole: _selectedConsole ?? '',
          usageHours:
              int.tryParse(_usageHoursController.text.trim()),
          consoleName: _consoleNameController.text.trim(),
          gameName: _gameNameController.text.trim(),
          pricingType:
              _isService ? _pricingType : 'Prix fixe',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedFamily == null
        ? <String>[]
        : _categoriesParFamille[_selectedFamily] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Déposer une annonce'),
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

          _textField(
            controller: _titleController,
            label: _isService
                ? 'Titre de la prestation'
                : 'Titre de l’annonce',
          ),

          _space(),

          if (!_isService)
            _textField(
              controller: _priceController,
              label: 'Prix',
              hint: 'Prix en FC',
              number: true,
            ),

          if (!_isService) _space(),

          DropdownButtonFormField<String>(
            value: _selectedFamily,
            isExpanded: true,
            decoration: _decoration(
              label: 'Famille',
            ),
            items: _categoriesParFamille.keys
                .map(
                  (family) => DropdownMenuItem(
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
                _priceController.clear();
                _resetSpecificFields();
              });
            },
          ),

          _space(),

          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration: _decoration(
              label: 'Sous-catégorie',
            ),
            items: categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            onChanged: _selectedFamily == null
                ? null
                : (value) {
                    setState(() {
                      _selectedCategory = value;
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

          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: _decoration(
              label: 'Ville',
            ),
            items: _communesParVille.keys
                .map(
                  (city) => DropdownMenuItem(
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

          DropdownButtonFormField<String>(
            value: _selectedCommune,
            decoration: _decoration(
              label: 'Commune',
            ),
            items: _selectedCity == null
                ? []
                : (_communesParVille[_selectedCity] ?? [])
                    .map(
                      (commune) => DropdownMenuItem(
                        value: commune,
                        child: Text(commune),
                      ),
                    )
                    .toList(),
            onChanged: _selectedCity == null
                ? null
                : (value) {
                    setState(() {
                      _selectedCommune = value;
                    });
                  },
          ),

          _space(),

          TextField(
            controller: _descriptionController,
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
              onPressed: _continueToPhotos,
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Continuer',
                style: TextStyle(fontSize: 17),
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
  State<AddPhotoScreen> createState() =>
      _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _image;

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library_outlined),
                title:
                    const Text('Choisir dans la galerie'),
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.gallery,
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt_outlined),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.camera,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() {
        _image = image;
      });
    }
  }

  void _continueToReview() {
    if (_image == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewAdScreen(
          title: widget.title,
          price: widget.price,
          city: widget.city,
          district: widget.district,
          description: widget.description,
          imagePath: _image!.path,
          family: widget.family,
          category: widget.category,
          brand: widget.brand,
          model: widget.model,
          manufactureYear: widget.manufactureYear,
          horsepower: widget.horsepower,
          fuelType: widget.fuelType,
          mileage: widget.mileage,
          itemCondition: widget.itemCondition,
          itemType: widget.itemType,
          compatibleConsole: widget.compatibleConsole,
          usageHours: widget.usageHours,
          consoleName: widget.consoleName,
          gameName: widget.gameName,
          pricingType: widget.pricingType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une photo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_image!.path),
                    fit: BoxFit.contain,
                  ),
                ),
              )
            else
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 60,
                ),
              ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _chooseImage,
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
              ),
              label: Text(
                _image == null
                    ? 'Ajouter une photo'
                    : 'Changer la photo',
              ),
            ),

            const SizedBox(height: 24),

            FilledButton(
              onPressed:
                  _image == null ? null : _continueToReview,
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// VÉRIFICATION ET PUBLICATION
// ==========================================================

class ReviewAdScreen extends StatefulWidget {
  final String title;
  final String price;
  final String city;
  final String district;
  final String description;
  final String imagePath;
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

  const ReviewAdScreen({
    super.key,
    required this.title,
    required this.price,
    required this.city,
    required this.district,
    required this.description,
    required this.imagePath,
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
  State<ReviewAdScreen> createState() =>
      _ReviewAdScreenState();
}

class _ReviewAdScreenState extends State<ReviewAdScreen> {
  bool _isPublishing = false;

  String get _displayPrice {
    if (widget.family == 'Prestations de services' &&
        widget.pricingType == 'Sur devis') {
      return 'Sur devis';
    }

    return '${widget.price} FC';
  }

  Future<void> _publishAd() async {
    if (_isPublishing) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Vous devez être connecté pour publier.',
        );
      }

      final imageFile = File(widget.imagePath);

      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('annonces')
          .upload(
            fileName,
            imageFile,
          );

      final imageUrl = supabase.storage
          .from('annonces')
          .getPublicUrl(fileName);

      final data = <String, dynamic>{
        'title': widget.title.trim(),
        'price': widget.price.trim(),
        'city': widget.city.trim(),
        'district': widget.district.trim(),
        'description': widget.description.trim(),
        'family': widget.family,
        'category': widget.category,
        'user_id': user.id,
        'imageUrl': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'brand':
            widget.brand.isEmpty ? null : widget.brand,
        'model':
            widget.model.isEmpty ? null : widget.model,
        'manufacture_year': widget.manufactureYear,
        'horsepower': widget.horsepower,
        'fuel_type': widget.fuelType.isEmpty
            ? null
            : widget.fuelType,
        'mileage': widget.mileage,
        'item_condition': widget.itemCondition.isEmpty
            ? null
            : widget.itemCondition,
        'item_type': widget.itemType.isEmpty
            ? null
            : widget.itemType,
        'compatible_console':
            widget.compatibleConsole.isEmpty
                ? null
                : widget.compatibleConsole,
        'usage_hours': widget.usageHours,
        'pricing_type': widget.pricingType,
      };

      if (widget.itemType == 'Console') {
        data['brand'] = widget.consoleName;
      }

      if (widget.itemType == 'Jeu') {
        data['model'] = widget.gameName;
      }

      final insertedData = await supabase
          .from('annonces')
          .insert(data)
          .select()
          .single();

      final annonce = Annonce.fromJson(
        Map<String, dynamic>.from(insertedData),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Annonce publiée avec succès',
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PlaceScreen(
            annonce: annonce,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la publication : $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  Widget _row(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label : $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérifier l’annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _displayPrice,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _row('Famille', widget.family),
            _row('Catégorie', widget.category),

            if (widget.brand.isNotEmpty)
              _row('Marque', widget.brand),

            if (widget.model.isNotEmpty)
              _row('Modèle', widget.model),

            if (widget.manufactureYear != null)
              _row(
                'Année',
                widget.manufactureYear.toString(),
              ),

            if (widget.horsepower != null)
              _row(
                'CV',
                widget.horsepower.toString(),
              ),

            if (widget.fuelType.isNotEmpty)
              _row(
                'Carburant',
                widget.fuelType,
              ),

            if (widget.mileage != null)
              _row(
                'Kilométrage',
                '${widget.mileage} km',
              ),

            if (widget.itemType.isNotEmpty)
              _row(
                'Type',
                widget.itemType,
              ),

            if (widget.compatibleConsole.isNotEmpty)
              _row(
                'Console compatible',
                widget.compatibleConsole,
              ),

            if (widget.usageHours != null)
              _row(
                'Heures d’utilisation',
                '${widget.usageHours} h',
              ),

            if (widget.itemCondition.isNotEmpty)
              _row(
                'État',
                widget.itemCondition,
              ),

            if (widget.family == 'Prestations de services')
              _row(
                'Tarification',
                widget.pricingType,
              ),

            _row('Ville', widget.city),
            _row('Commune', widget.district),

            const SizedBox(height: 12),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(widget.description),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed:
                    _isPublishing ? null : _publishAd,
                child: _isPublishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Publier l’annonce',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
