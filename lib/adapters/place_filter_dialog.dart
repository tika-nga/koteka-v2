import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KotekaFilterResult {
  final int? minPrice;
  final int? maxPrice;
  final String? city;
  final String? commune;
  final int? distanceKm;
  final String? vehicleCategory;
  final String? brand;
  final String? model;
  final int? manufactureYear;
  final String? vehicleType;
  final String? fuelType;
  final String? transmission;
  final int? maxMileage;
  final String? vehicleCondition;
  final int? doorCount;
  final int? seatCount;

  const KotekaFilterResult({
    this.minPrice,
    this.maxPrice,
    this.city,
    this.commune,
    this.distanceKm,
    this.vehicleCategory,
    this.brand,
    this.model,
    this.manufactureYear,
    this.vehicleType,
    this.fuelType,
    this.transmission,
    this.maxMileage,
    this.vehicleCondition,
    this.doorCount,
    this.seatCount,
  });
}

Future<KotekaFilterResult?> showPlaceFilterDialog(
  BuildContext context, {
  int? initialMinPrice,
  int? initialMaxPrice,
  String? initialCity,
  String? initialCommune,
  int? initialDistanceKm,
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
            initialDistanceKm: initialDistanceKm,
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
  final int? initialDistanceKm;

  const Filter({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialCity,
    this.initialCommune,
    this.initialDistanceKm,
  });

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _yearController;
  late final TextEditingController _maxMileageController;

  String? _selectedCity;
  String? _selectedCommune;
  int? _selectedDistanceKm;
  String? _vehicleCategory;
  String? _brand;
  String? _model;
  String? _vehicleType;
  String? _fuelType;
  String? _transmission;
  String? _vehicleCondition;
  int? _doorCount;
  int? _seatCount;

  final List<int> _distances = [1, 5, 10, 20, 50, 100];
  final List<String> _vehicleCategories = ['Voitures', 'Camions'];
  final List<String> _vehicleTypes = [
    'Berline', 'Break', 'Citadine', 'Coupé', 'Cabriolet',
    'Monospace', 'SUV / 4x4', 'Pick-up', 'Utilitaire',
  ];
  final List<String> _fuels = [
    'Essence', 'Gasoil', 'Hybride', 'Électrique', 'GPL',
  ];
  final List<String> _transmissions = ['Auto', 'Manuel'];
  final List<String> _conditions = [
    'Neuf', 'Comme neuf', 'Bon état', 'État correct', 'Pour pièces',
  ];

  final Map<String, List<String>> _modelsByBrand = {
    'Audi': ['A1','A3','A4','A5','A6','A8','Q2','Q3','Q5','Q7','Autre'],
    'BMW': ['Série 1','Série 2','Série 3','Série 4','Série 5','Série 7','X1','X3','X5','X6','Autre'],
    'Chevrolet': ['Aveo','Captiva','Cruze','Spark','Tahoe','Trailblazer','Autre'],
    'Chrysler': ['300','Grand Voyager','Pacifica','PT Cruiser','Voyager','Autre'],
    'Citroën': ['C1','C2','C3','C4','C4 Picasso','C5','Berlingo','Jumpy','Xsara Picasso','Autre'],
    'Dacia': ['Duster','Logan','Sandero','Lodgy','Dokker','Autre'],
    'Fiat': ['500','Panda','Punto','Tipo','Doblo','Ducato','Autre'],
    'Ford': ['Fiesta','Focus','Mondeo','Kuga','EcoSport','Ranger','Transit','Autre'],
    'Honda': ['Civic','Accord','CR-V','HR-V','Jazz','Autre'],
    'Hyundai': ['i10','i20','i30','Accent','Elantra','Tucson','Santa Fe','Autre'],
    'Isuzu': ['D-Max','MU-X','Trooper','Autre'],
    'Jeep': ['Cherokee','Grand Cherokee','Compass','Renegade','Wrangler','Autre'],
    'Kia': ['Picanto','Rio','Ceed','Sportage','Sorento','Carnival','Autre'],
    'Land Rover': ['Defender','Discovery','Freelander','Range Rover','Range Rover Evoque','Range Rover Sport','Autre'],
    'Lexus': ['CT','ES','GS','IS','NX','RX','LX','Autre'],
    'Mazda': ['Mazda 2','Mazda 3','Mazda 6','CX-3','CX-5','CX-7','CX-9','BT-50','Autre'],
    'Mercedes-Benz': ['Classe A','Classe B','Classe C','Classe E','Classe S','CLA','CLS','GLA','GLC','GLE','GLS','Vito','Sprinter','Autre'],
    'Mitsubishi': ['Colt','Lancer','ASX','Outlander','Pajero','L200','Autre'],
    'Nissan': ['Micra','Juke','Qashqai','X-Trail','Pathfinder','Patrol','Navara','Primastar','Autre'],
    'Opel': ['Corsa','Astra','Insignia','Meriva','Zafira','Mokka','Vivaro','Autre'],
    'Peugeot': ['108','206','207','208','307','308','407','508','2008','3008','5008','Partner','Expert','Boxer','Autre'],
    'Renault': ['Twingo','Clio','Mégane','Laguna','Scénic','Captur','Kadjar','Koleos','Kangoo','Trafic','Master','Autre'],
    'Seat': ['Ibiza','Leon','Toledo','Altea','Ateca','Autre'],
    'Škoda': ['Fabia','Octavia','Superb','Karoq','Kodiaq','Autre'],
    'Subaru': ['Impreza','Legacy','Forester','Outback','XV','Autre'],
    'Suzuki': ['Alto','Swift','Vitara','Grand Vitara','Jimny','SX4','Autre'],
    'Toyota': ['Aygo','Yaris','Corolla','Avensis','Camry','RAV4','Land Cruiser','Hilux','Prado','Fortuner','Hiace','Autre'],
    'Volkswagen': ['Polo','Golf','Passat','Touran','Tiguan','Touareg','Caddy','Transporter','Autre'],
    'Volvo': ['S40','S60','S80','V40','V60','XC40','XC60','XC90','Autre'],
  };

  final Map<String, List<String>> _communesParVille = {
    'Kinshasa': [
      'Bandalungwa','Barumbu','Bumbu','Gombe','Kalamu','Kasa-Vubu',
      'Kimbanseke','Kinshasa','Kintambo','Kisenso','Lemba','Limete',
      'Lingwala','Makala','Maluku','Masina','Matete','Mont-Ngafula',
      'Ndjili','Ngaba','Ngaliema','Ngiri-Ngiri','Nsele','Selembao',
    ],
  };

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(text: widget.initialMinPrice?.toString() ?? '');
    _maxPriceController = TextEditingController(text: widget.initialMaxPrice?.toString() ?? '');
    _yearController = TextEditingController();
    _maxMileageController = TextEditingController();
    _selectedCity = widget.initialCity;
    _selectedDistanceKm = widget.initialDistanceKm;
    if (_selectedCity != null && (_communesParVille[_selectedCity] ?? []).contains(widget.initialCommune)) {
      _selectedCommune = widget.initialCommune;
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _yearController.dispose();
    _maxMileageController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final minPrice = int.tryParse(_minPriceController.text.trim());
    final maxPrice = int.tryParse(_maxPriceController.text.trim());
    if (minPrice != null && maxPrice != null && maxPrice < minPrice) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Le prix maximum ne peut pas être inférieur au prix minimum.'),
      ));
      return;
    }
    Navigator.of(context).pop(KotekaFilterResult(
      minPrice: minPrice,
      maxPrice: maxPrice,
      city: _selectedCity,
      commune: _selectedCommune,
      distanceKm: _selectedDistanceKm,
      vehicleCategory: _vehicleCategory,
      brand: _brand,
      model: _model,
      manufactureYear: int.tryParse(_yearController.text.trim()),
      vehicleType: _vehicleType,
      fuelType: _fuelType,
      transmission: _transmission,
      maxMileage: int.tryParse(_maxMileageController.text.trim()),
      vehicleCondition: _vehicleCondition,
      doorCount: _doorCount,
      seatCount: _seatCount,
    ));
  }

  void _resetFilter() => Navigator.of(context).pop(const KotekaFilterResult());

  Widget _drop<T>(String label, T? value, List<T> values, ValueChanged<T?> onChanged) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: values.map((v) => DropdownMenuItem<T>(value: v, child: Text(v.toString()))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isCar = _vehicleCategory == 'Voitures';
    final isTruck = _vehicleCategory == 'Camions';
    final seatValues = isTruck ? <int>[2, 3] : <int>[2, 4, 5, 6, 7];
    final modelValues = _brand == null ? <String>[] : (_modelsByBrand[_brand] ?? <String>[]);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('Filtrer les annonces', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primaryColor))),
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        ]),
        const Divider(), const SizedBox(height: 12),
        Text('Prix (FC)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: _minPriceController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Minimum', border: OutlineInputBorder()))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _maxPriceController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Maximum', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 20),
        _drop<String>('Catégorie véhicule', _vehicleCategory, _vehicleCategories, (v) => setState(() { _vehicleCategory = v; _doorCount = null; _seatCount = null; })),
        if (isCar || isTruck) ...[
          const SizedBox(height: 14),
          _drop<String>('Marque', _brand, _modelsByBrand.keys.toList(), (v) => setState(() { _brand = v; _model = null; })),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(value: modelValues.contains(_model) ? _model : null, isExpanded: true, decoration: const InputDecoration(labelText: 'Modèle', border: OutlineInputBorder()), items: modelValues.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: _brand == null ? null : (v) => setState(() => _model = v)),
          const SizedBox(height: 14),
          TextField(controller: _yearController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Année-Modèle', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          _drop<String>('Type de véhicule', _vehicleType, _vehicleTypes, (v) => setState(() => _vehicleType = v)),
          const SizedBox(height: 14),
          _drop<String>('Énergie', _fuelType, _fuels, (v) => setState(() => _fuelType = v)),
          const SizedBox(height: 14),
          _drop<String>('Boîte de vitesse', _transmission, _transmissions, (v) => setState(() => _transmission = v)),
          const SizedBox(height: 14),
          TextField(controller: _maxMileageController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Kilométrage maximum', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          _drop<String>('État du véhicule', _vehicleCondition, _conditions, (v) => setState(() => _vehicleCondition = v)),
          if (isCar) ...[
            const SizedBox(height: 14),
            _drop<int>('Nombre de portes', _doorCount, const [3, 5], (v) => setState(() => _doorCount = v)),
          ],
          const SizedBox(height: 14),
          _drop<int>('Nombre de places', seatValues.contains(_seatCount) ? _seatCount : null, seatValues, (v) => setState(() => _seatCount = v)),
        ],
        const SizedBox(height: 22),
        Text('Distance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor)),
        const SizedBox(height: 8),
        _drop<int>('Rayon de recherche', _selectedDistanceKm, _distances, (v) => setState(() => _selectedDistanceKm = v)),
        const SizedBox(height: 22),
        _drop<String>('Ville', _selectedCity, _communesParVille.keys.toList(), (v) => setState(() { _selectedCity = v; _selectedCommune = null; })),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(value: _selectedCommune, isExpanded: true, decoration: const InputDecoration(labelText: 'Commune', border: OutlineInputBorder()), items: _selectedCity == null ? const [] : (_communesParVille[_selectedCity] ?? []).map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: _selectedCity == null ? null : (v) => setState(() => _selectedCommune = v)),
        const SizedBox(height: 22),
        Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 10, children: [
          OutlinedButton(onPressed: _resetFilter, child: const Text('Réinitialiser')),
          ElevatedButton.icon(onPressed: _applyFilter, icon: const Icon(Icons.tune), label: const Text('Filtrer')),
        ]),
      ]),
    );
  }
}
