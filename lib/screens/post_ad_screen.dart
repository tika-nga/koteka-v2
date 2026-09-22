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

  String? _selectedFamily;
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedCommune;

  final Map<String, List<String>> _categoriesParFamille = {
    'Véhicules': [
      'Voitures',
      'Camions',
      'Motos',
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
      'Ameublement',
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

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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

  Future<void> _continueToPhotos() async {
    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final description =
        _descriptionController.text.trim();

    if (title.isEmpty) {
      _showMessage(
        'Veuillez saisir le titre de l’annonce.',
      );
      return;
    }

    if (price.isEmpty ||
        int.tryParse(price) == null) {
      _showMessage(
        'Veuillez saisir un prix valide.',
      );
      return;
    }

    if (_selectedFamily == null) {
      _showMessage(
        'Veuillez choisir une famille.',
      );
      return;
    }

    if (_selectedCategory == null) {
      _showMessage(
        'Veuillez choisir une sous-catégorie.',
      );
      return;
    }

    if (_selectedCity == null) {
      _showMessage(
        'Veuillez choisir une ville.',
      );
      return;
    }

    if (_selectedCommune == null) {
      _showMessage(
        'Veuillez choisir une commune.',
      );
      return;
    }

    if (description.isEmpty) {
      _showMessage(
        'Veuillez ajouter une description.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPhotoScreen(
          title: title,
          price: price,
          city: _selectedCity!,
          district: _selectedCommune!,
          description: description,
          family: _selectedFamily!,
          category: _selectedCategory!,
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
                <String>[];

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
            'Que voulez-vous vendre ?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _titleController,
            decoration: _decoration(
              label: 'Titre de l’annonce',
              hint: 'Ex : Samsung Galaxy S22',
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: _decoration(
              label: 'Prix',
              hint: 'Prix en FC',
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedFamily,
            isExpanded: true,
            decoration: _decoration(
              label: 'Famille',
            ),
            hint: const Text(
              'Choisir une famille',
            ),
            items:
                _categoriesParFamille.keys.map(
              (family) {
                return DropdownMenuItem<String>(
                  value: family,
                  child: Text(family),
                );
              },
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFamily = value;
                _selectedCategory = null;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration: _decoration(
              label: 'Sous-catégorie',
            ),
            hint: Text(
              _selectedFamily == null
                  ? 'Choisissez d’abord une famille'
                  : 'Choisir une sous-catégorie',
            ),
            items: categories.map(
              (category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                );
              },
            ).toList(),
            onChanged:
                _selectedFamily == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategory =
                              value;
                        });
                      },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCity,
            isExpanded: true,
            decoration: _decoration(
              label: 'Ville',
            ),
            hint: const Text(
              'Choisir une ville',
            ),
            items:
                _communesParVille.keys.map(
              (ville) {
                return DropdownMenuItem<String>(
                  value: ville,
                  child: Text(ville),
                );
              },
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedCommune = null;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCommune,
            isExpanded: true,
            decoration: _decoration(
              label: 'Commune',
            ),
            hint: Text(
              _selectedCity == null
                  ? 'Choisissez d’abord une ville'
                  : 'Choisir une commune',
            ),
            items: _selectedCity == null
                ? <DropdownMenuItem<String>>[]
                : (_communesParVille[
                            _selectedCity] ??
                        [])
                    .map(
                      (commune) =>
                          DropdownMenuItem<
                              String>(
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

          const SizedBox(height: 16),

          TextField(
            controller:
                _descriptionController,
            maxLines: 5,
            decoration: _decoration(
              label: 'Description',
              hint: 'Décrivez votre article',
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La localisation de l’annonce '
                    'sera enregistrée à partir de '
                    'la ville et de la commune '
                    'sélectionnées.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: _continueToPhotos,
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
// AJOUT PHOTO
// ==========================================================

class AddPhotoScreen extends StatefulWidget {
  final String title;
  final String price;
  final String city;
  final String district;
  final String description;
  final String family;
  final String category;

  const AddPhotoScreen({
    super.key,
    required this.title,
    required this.price,
    required this.city,
    required this.district,
    required this.description,
    required this.family,
    required this.category,
  });

  @override
  State<AddPhotoScreen> createState() =>
      _AddPhotoScreenState();
}

class _AddPhotoScreenState
    extends State<AddPhotoScreen> {
  final ImagePicker _picker =
      ImagePicker();

  XFile? _image;

  Future<void> _chooseImage() async {
    final source =
        await showModalBottomSheet<
            ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons
                      .photo_library_outlined,
                ),
                title: const Text(
                  'Choisir dans la galerie',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                ),
                title: const Text(
                  'Prendre une photo',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final image =
        await _picker.pickImage(
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
    if (_image == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReviewAdScreen(
          title: widget.title,
          price: widget.price,
          city: widget.city,
          district: widget.district,
          description:
              widget.description,
          imagePath: _image!.path,
          family: widget.family,
          category: widget.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Ajouter des photos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajoutez une photo de votre article',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            if (_image != null)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                          12),
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
                  borderRadius:
                      BorderRadius.circular(
                          12),
                  color:
                      Colors.grey.shade200,
                ),
                child: const Center(
                  child: Icon(
                    Icons
                        .add_photo_alternate_outlined,
                    size: 60,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _chooseImage,
              icon: const Icon(
                Icons
                    .add_photo_alternate_outlined,
              ),
              label: Text(
                _image == null
                    ? 'Ajouter une photo'
                    : 'Changer la photo',
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _image == null
                  ? null
                  : _continueToReview,
              icon: const Icon(
                Icons.arrow_forward,
              ),
              label: const Text(
                'Continuer',
                style:
                    TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// VÉRIFICATION + PUBLICATION
// ==========================================================

class ReviewAdScreen
    extends StatefulWidget {
  final String title;
  final String price;
  final String city;
  final String district;
  final String description;
  final String imagePath;
  final String family;
  final String category;

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
  });

  @override
  State<ReviewAdScreen> createState() =>
      _ReviewAdScreenState();
}

class _ReviewAdScreenState
    extends State<ReviewAdScreen> {
  bool _isPublishing = false;

  Future<void> _publishAd() async {
    if (_isPublishing) {
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final supabase =
          Supabase.instance.client;

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Vous devez être connecté pour publier une annonce.',
            ),
          ),
        );

        return;
      }

      final imageFile =
          File(widget.imagePath);

      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('annonces')
          .upload(
            fileName,
            imageFile,
          );

      final imageUrl =
          supabase.storage
              .from('annonces')
              .getPublicUrl(
                fileName,
              );

      final insertedData =
          await supabase
              .from('annonces')
              .insert({
                'title':
                    widget.title.trim(),
                'price':
                    widget.price.trim(),
                'city':
                    widget.city.trim(),
                'district':
                    widget.district.trim(),
                'description':
                    widget.description
                        .trim(),
                'family':
                    widget.family,
                'category':
                    widget.category,
                'user_id':
                    user.id,
                'imageUrl':
                    imageUrl,
                'created_at':
                    DateTime.now()
                        .toIso8601String(),
              })
              .select()
              .single();

      final annonce =
          Annonce.fromJson(
        Map<String, dynamic>.from(
          insertedData,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Annonce publiée avec succès',
          ),
        ),
      );

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PlaceScreen(
            annonce: annonce,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  Widget _informationRow(
    String label,
    String value,
  ) {
    return Text(
      '$label : $value',
      style: const TextStyle(
        fontSize: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Vérifier l’annonce'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius:
                    BorderRadius.circular(
                        12),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                        12),
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
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '${widget.price} FC',
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _informationRow(
              'Famille',
              widget.family,
            ),

            const SizedBox(height: 8),

            _informationRow(
              'Sous-catégorie',
              widget.category,
            ),

            const SizedBox(height: 8),

            _informationRow(
              'Ville',
              widget.city,
            ),

            const SizedBox(height: 8),

            _informationRow(
              'Commune',
              widget.district,
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isPublishing
                    ? null
                    : _publishAd,
                child: _isPublishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Publier l’annonce',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
