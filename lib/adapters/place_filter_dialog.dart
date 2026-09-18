import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KotekaFilterResult {
  final int? minPrice;
  final int? maxPrice;
  final String? city;
  final String? commune;

  const KotekaFilterResult({
    this.minPrice,
    this.maxPrice,
    this.city,
    this.commune,
  });
}

Future<KotekaFilterResult?> showPlaceFilterDialog(
  BuildContext context, {
  int? initialMinPrice,
  int? initialMaxPrice,
  String? initialCity,
  String? initialCommune,
}) async {
  return showDialog<KotekaFilterResult>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Filter(
            initialMinPrice: initialMinPrice,
            initialMaxPrice: initialMaxPrice,
            initialCity: initialCity,
            initialCommune: initialCommune,
          ),
        ),
      ),
    ),
  );
}

class Filter extends StatefulWidget {
  final int? initialMinPrice;
  final int? initialMaxPrice;
  final String? initialCity;
  final String? initialCommune;

  const Filter({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialCity,
    this.initialCommune,
  });

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  String? _selectedCity;
  String? _selectedCommune;

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
  void initState() {
    super.initState();

    _minPriceController = TextEditingController(
      text: widget.initialMinPrice?.toString() ?? '',
    );

    _maxPriceController = TextEditingController(
      text: widget.initialMaxPrice?.toString() ?? '',
    );

    _selectedCity = widget.initialCity;

    if (_selectedCity != null &&
        (_communesParVille[_selectedCity] ?? [])
            .contains(widget.initialCommune)) {
      _selectedCommune = widget.initialCommune;
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final minPrice =
        int.tryParse(_minPriceController.text.trim());

    final maxPrice =
        int.tryParse(_maxPriceController.text.trim());

    if (minPrice != null &&
        maxPrice != null &&
        maxPrice < minPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le prix maximum ne peut pas être inférieur au prix minimum.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      KotekaFilterResult(
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: _selectedCity,
        commune: _selectedCommune,
      ),
    );
  }

  void _resetFilter() {
    Navigator.of(context).pop(
      const KotekaFilterResult(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrer les annonces',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const Divider(),
          const SizedBox(height: 12),

          Text(
            'Prix (FC)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Minimum',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Maximum',
                    hintText: 'Ex : 50000',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _selectedCity,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Ville',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Toutes les villes'),
            items: _communesParVille.keys.map((ville) {
              return DropdownMenuItem<String>(
                value: ville,
                child: Text(ville),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedCommune = null;
              });
            },
          ),

          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            value: _selectedCommune,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Commune',
              border: OutlineInputBorder(),
            ),
            hint: Text(
              _selectedCity == null
                  ? 'Choisissez d’abord une ville'
                  : 'Toutes les communes',
            ),
            items: _selectedCity == null
                ? const []
                : (_communesParVille[_selectedCity] ?? [])
                    .map(
                      (commune) =>
                          DropdownMenuItem<String>(
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

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _resetFilter,
                child: const Text('Réinitialiser'),
              ),

              const SizedBox(width: 12),

              ElevatedButton.icon(
                onPressed: _applyFilter,
                icon: const Icon(Icons.tune),
                label: const Text('Filtrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
