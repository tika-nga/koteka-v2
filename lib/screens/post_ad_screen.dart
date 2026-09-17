import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _descriptionController = TextEditingController();
String? _selectedCategory;

final List<String> _categories = [
  'Voiture',
  'Pièces automobiles',
  'Moto',
  'Pièces motos',
  'Meubles',
  'Vélos',
  'Divers',
];

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

String? _selectedCity;
String? _selectedCommune;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Déposer une annonce'),
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
  decoration: InputDecoration(
              labelText: 'Titre de l’annonce',
              hintText: 'Ex : Samsung Galaxy S22',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
  controller: _priceController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: 'Prix',
    hintText: 'Prix en FC',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

          const SizedBox(height: 16),

          TextField(
  controller: _cityController,
  decoration: InputDecoration(
    labelText: 'Ville',
    hintText: 'Ex : Kinshasa',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

          const SizedBox(height: 16),

          TextField(
  controller: _districtController,
  decoration: InputDecoration(
    labelText: 'Quartier',
    hintText: 'Ex : Gombe',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

          const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: _selectedCategory,
  decoration: InputDecoration(
    labelText: 'Catégorie',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  hint: const Text('Choisir une catégorie'),
  items: _categories.map((category) {
    return DropdownMenuItem<String>(
      value: category,
      child: Text(category),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedCategory = value;
    });
  },
),
          
          const SizedBox(height: 16),

          TextField(
  controller: _descriptionController,
  maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Décrivez votre article',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

                      const SizedBox(height: 24),

            SizedBox(
              height: 55,
              child: FilledButton.icon(
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddPhotoScreen(
  title: _titleController.text,
  price: _priceController.text,
  city: _cityController.text,
  district: _districtController.text,
  description: _descriptionController.text,
  category: _selectedCategory ?? 'Divers',
),
    ),
  );
},
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

class AddPhotoScreen extends StatefulWidget {
  final String title;
  final String price;
  final String city;
  final String district;
  final String description;
  final String category;

  const AddPhotoScreen({
    super.key,
    required this.title,
    required this.price,
    required this.city,
    required this.district,
    required this.description,
    required this.category,
  });
  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter des photos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajoutez une photo de votre article',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_image!.path),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
  onPressed: _chooseImage,
  icon: const Icon(Icons.add_photo_alternate_outlined),
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
    : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewAdScreen(
  title: widget.title,
  price: widget.price,
  city: widget.city,
  district: widget.district,
  description: widget.description,
  imagePath: _image!.path,
  category: widget.category,
),
          ),
        );
      },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Continuer',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
          );
  }
}
      class ReviewAdScreen extends StatelessWidget {
  final String title;
  final String price;
  final String city;
  final String district;
  final String description;
  final String imagePath;
  final String category;

  const ReviewAdScreen({
    super.key,
    required this.title,
    required this.price,
    required this.city,
    required this.district,
    required this.description,
    required this.imagePath,
    required this.category,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérifier l’annonce'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          height: 220,
          fit: BoxFit.cover,
        ),
      ),

      const SizedBox(height: 24),

      Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 12),

      Text(
        '$price FC',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      Text(
        'Ville : $city',
        style: const TextStyle(fontSize: 17),
      ),

      const SizedBox(height: 8),

      Text(
        'Commune : $district',
        style: const TextStyle(fontSize: 17),
      ),

      const SizedBox(height: 20),

      const Text(
        'Description',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      Text(
        description,
        style: const TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 32),

      FilledButton(
  onPressed: () async {
    try {
      final imageFile = File(imagePath);

final supabase = Supabase.instance.client;

final fileName =
    '${DateTime.now().millisecondsSinceEpoch}.jpg';

await supabase.storage
    .from('annonces')
    .upload(fileName, imageFile);

final imageUrl = supabase.storage
    .from('annonces')
    .getPublicUrl(fileName);

await supabase.from('annonces').insert({
  'title': title.trim(),
  'price': price.trim(),
  'city': city.trim(),
  'district': district.trim(),
  'description': description.trim(),
  'category': category,
  'imageUrl': imageUrl,
  'created_at': DateTime.now().toIso8601String(),
});

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce publiée avec succès'),
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la publication : $e'),
        ),
      );
    }
  },
        child: const Text('Publier l’annonce'),
    ),
        ],
      ),
    ),
  );
}
}
