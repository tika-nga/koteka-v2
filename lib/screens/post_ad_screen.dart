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

  String? _selectedCarBrand;
  String? _selectedCarModel;
  String? _selectedVehicleType;
  String? _selectedTransmission;
  String? _selectedMotorization;
  String? _selectedDoorCount;
  String? _selectedSeatCount;

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
    'Hybride',
  ];

  final List<String> _vehicleTypes = [
    'Berline',
    'Break',
    'Citadine',
    'Coupé',
    'Cabriolet',
    'Monospace',
    'SUV / 4x4',
    'Pick-up',
    'Utilitaire',
  ];

  final List<String> _transmissions = [
    'Auto',
    'Manuel',
  ];

  final List<String> _motorizations = [
    '0.8 L', '0.9 L', '1.0 L', '1.1 L', '1.2 L', '1.3 L',
    '1.4 L', '1.5 L', '1.6 L', '1.7 L', '1.8 L', '1.9 L',
    '2.0 L', '2.2 L', '2.3 L', '2.4 L', '2.5 L', '2.7 L',
    '2.8 L', '3.0 L', '3.2 L', '3.5 L', '3.6 L', '4.0 L',
    '4.2 L', '4.4 L', '4.5 L', '4.6 L', '5.0 L', '5.5 L',
    '6.0 L', 'Électrique', 'Autre motorisation',
  ];

  final List<String> _carDoorCounts = ['3', '5'];
  final List<String> _carSeatCounts = ['2', '4', '5', '6', '7'];
  final List<String> _truckSeatCounts = ['2', '3'];

  final Map<String, List<String>> _carModelsByBrand = {
    'Audi': ['A1', 'A3', 'A4', 'A5', 'A6', 'A8', 'Q2', 'Q3', 'Q5', 'Q7', 'Autre'],
    'BMW': ['Série 1', 'Série 2', 'Série 3', 'Série 4', 'Série 5', 'Série 7', 'X1', 'X3', 'X5', 'X6', 'Autre'],
    'Chevrolet': ['Aveo', 'Captiva', 'Cruze', 'Spark', 'Tahoe', 'Trailblazer', 'Autre'],
    'Chrysler': ['300', 'Grand Voyager', 'Pacifica', 'PT Cruiser', 'Voyager', 'Autre'],
    'Citroën': ['C1', 'C2', 'C3', 'C4', 'C4 Picasso', 'C5', 'Berlingo', 'Jumpy', 'Xsara Picasso', 'Autre'],
    'Dacia': ['Duster', 'Logan', 'Sandero', 'Lodgy', 'Dokker', 'Autre'],
    'Fiat': ['500', 'Panda', 'Punto', 'Tipo', 'Doblo', 'Ducato', 'Autre'],
    'Ford': ['Fiesta', 'Focus', 'Mondeo', 'Kuga', 'EcoSport', 'Ranger', 'Transit', 'Autre'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'HR-V', 'Jazz', 'Autre'],
    'Hyundai': ['i10', 'i20', 'i30', 'Accent', 'Elantra', 'Tucson', 'Santa Fe', 'Autre'],
    'Isuzu': ['D-Max', 'MU-X', 'Trooper', 'Autre'],
    'Jeep': ['Cherokee', 'Grand Cherokee', 'Compass', 'Renegade', 'Wrangler', 'Autre'],
    'Kia': ['Picanto', 'Rio', 'Ceed', 'Sportage', 'Sorento', 'Carnival', 'Autre'],
    'Land Rover': ['Defender', 'Discovery', 'Freelander', 'Range Rover', 'Range Rover Evoque', 'Range Rover Sport', 'Autre'],
    'Lexus': ['CT', 'ES', 'GS', 'IS', 'NX', 'RX', 'LX', 'Autre'],
    'Mazda': ['Mazda 2', 'Mazda 3', 'Mazda 6', 'CX-3', 'CX-5', 'CX-7', 'CX-9', 'BT-50', 'Autre'],
    'Mercedes-Benz': ['Classe A', 'Classe B', 'Classe C', 'Classe E', 'Classe S', 'CLA', 'CLS', 'GLA', 'GLC', 'GLE', 'GLS', 'Vito', 'Sprinter', 'Autre'],
    'Mitsubishi': ['Colt', 'Lancer', 'ASX', 'Outlander', 'Pajero', 'L200', 'Autre'],
    'Nissan': ['Micra', 'Juke', 'Qashqai', 'X-Trail', 'Pathfinder', 'Patrol', 'Navara', 'Primastar', 'Autre'],
    'Opel': ['Corsa', 'Astra', 'Insignia', 'Meriva', 'Zafira', 'Mokka', 'Vivaro', 'Autre'],
    'Peugeot': ['108', '206', '207', '208', '307', '308', '407', '508', '2008', '3008', '5008', 'Partner', 'Expert', 'Boxer', 'Autre'],
    'Renault': ['Twingo', 'Clio', 'Mégane', 'Laguna', 'Scénic', 'Captur', 'Kadjar', 'Koleos', 'Kangoo', 'Trafic', 'Master', 'Autre'],
    'Seat': ['Ibiza', 'Leon', 'Toledo', 'Altea', 'Ateca', 'Autre'],
    'Škoda': ['Fabia', 'Octavia', 'Superb', 'Karoq', 'Kodiaq', 'Autre'],
    'Subaru': ['Impreza', 'Legacy', 'Forester', 'Outback', 'XV', 'Autre'],
    'Suzuki': ['Alto', 'Swift', 'Vitara', 'Grand Vitara', 'Jimny', 'SX4', 'Autre'],
    'Toyota': ['Aygo', 'Yaris', 'Corolla', 'Avensis', 'Camry', 'RAV4', 'Land Cruiser', 'Prado', 'Fortuner', 'Hilux', 'Hiace', 'Autre'],
    'Volkswagen': ['Polo', 'Golf', 'Passat', 'Touran', 'Tiguan', 'Touareg', 'Caddy', 'Transporter', 'Autre'],
    'Volvo': ['S40', 'S60', 'S80', 'V40', 'V60', 'XC40', 'XC60', 'XC90', 'Autre'],
  };


  // Motorisations courantes par modèle. La liste reste volontairement courte.
  // "Autre motorisation" permet de couvrir les versions rares ou propres à un marché.
  final Map<String, List<String>> _carMotorizationsByModel = {
    'Audi|A1': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','2.0 L'],
    'Audi|A3': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','1.8 L','1.9 L','2.0 L'],
    'Audi|A4': ['1.4 L','1.6 L','1.8 L','1.9 L','2.0 L','2.5 L','2.7 L','3.0 L'],
    'Audi|A5': ['1.8 L','2.0 L','2.7 L','3.0 L','3.2 L'],
    'Audi|A6': ['1.8 L','1.9 L','2.0 L','2.5 L','2.7 L','3.0 L','3.2 L','4.2 L'],
    'Audi|A8': ['2.8 L','3.0 L','3.2 L','4.0 L','4.2 L'],
    'Audi|Q2': ['1.0 L','1.4 L','1.5 L','1.6 L','2.0 L'],
    'Audi|Q3': ['1.4 L','1.5 L','2.0 L'], 'Audi|Q5': ['2.0 L','3.0 L','3.2 L'], 'Audi|Q7': ['3.0 L','3.6 L','4.2 L'],
    'BMW|Série 1': ['1.5 L','1.6 L','2.0 L','3.0 L'], 'BMW|Série 2': ['1.5 L','2.0 L','3.0 L'],
    'BMW|Série 3': ['1.6 L','1.8 L','2.0 L','2.5 L','3.0 L'], 'BMW|Série 4': ['2.0 L','3.0 L'],
    'BMW|Série 5': ['2.0 L','2.5 L','3.0 L','4.4 L'], 'BMW|Série 7': ['3.0 L','4.0 L','4.4 L'],
    'BMW|X1': ['1.5 L','2.0 L'], 'BMW|X3': ['2.0 L','3.0 L'], 'BMW|X5': ['2.0 L','3.0 L','4.4 L'], 'BMW|X6': ['3.0 L','4.4 L'],
    'Chevrolet|Aveo': ['1.2 L','1.4 L','1.6 L'], 'Chevrolet|Captiva': ['2.0 L','2.2 L','2.4 L','3.0 L'],
    'Chevrolet|Cruze': ['1.4 L','1.6 L','1.8 L','2.0 L'], 'Chevrolet|Spark': ['0.8 L','1.0 L','1.2 L'],
    'Chevrolet|Tahoe': ['4.8 L','5.3 L','6.0 L'], 'Chevrolet|Trailblazer': ['2.5 L','2.8 L','3.6 L'],
    'Chrysler|300': ['2.7 L','3.0 L','3.5 L','3.6 L','5.7 L'], 'Chrysler|Grand Voyager': ['2.5 L','2.8 L','3.3 L','3.6 L'],
    'Chrysler|Pacifica': ['3.5 L','3.6 L','4.0 L'], 'Chrysler|PT Cruiser': ['1.6 L','2.0 L','2.2 L','2.4 L'], 'Chrysler|Voyager': ['2.5 L','2.8 L','3.3 L','3.6 L'],
    'Citroën|C1': ['1.0 L','1.2 L','1.4 L'], 'Citroën|C2': ['1.1 L','1.4 L','1.6 L'], 'Citroën|C3': ['1.0 L','1.1 L','1.2 L','1.4 L','1.5 L','1.6 L'],
    'Citroën|C4': ['1.2 L','1.4 L','1.5 L','1.6 L','2.0 L'], 'Citroën|C4 Picasso': ['1.2 L','1.6 L','2.0 L'], 'Citroën|C5': ['1.6 L','1.8 L','2.0 L','2.2 L','2.7 L','3.0 L'],
    'Citroën|Berlingo': ['1.2 L','1.4 L','1.5 L','1.6 L','1.9 L','2.0 L'], 'Citroën|Jumpy': ['1.6 L','2.0 L'], 'Citroën|Xsara Picasso': ['1.6 L','1.8 L','2.0 L'],
    'Dacia|Duster': ['1.0 L','1.2 L','1.3 L','1.5 L','1.6 L'], 'Dacia|Logan': ['0.9 L','1.0 L','1.2 L','1.4 L','1.5 L','1.6 L'],
    'Dacia|Sandero': ['0.9 L','1.0 L','1.2 L','1.4 L','1.5 L','1.6 L'], 'Dacia|Lodgy': ['1.2 L','1.3 L','1.5 L','1.6 L'], 'Dacia|Dokker': ['1.2 L','1.5 L','1.6 L'],
    'Fiat|500': ['0.9 L','1.0 L','1.2 L','1.3 L','1.4 L'], 'Fiat|Panda': ['0.9 L','1.0 L','1.1 L','1.2 L','1.3 L','1.4 L'],
    'Fiat|Punto': ['1.2 L','1.3 L','1.4 L','1.6 L','1.9 L'], 'Fiat|Tipo': ['1.0 L','1.3 L','1.4 L','1.6 L'], 'Fiat|Doblo': ['1.2 L','1.3 L','1.4 L','1.6 L','1.9 L','2.0 L'], 'Fiat|Ducato': ['2.0 L','2.2 L','2.3 L','2.8 L','3.0 L'],
    'Ford|Fiesta': ['1.0 L','1.1 L','1.2 L','1.3 L','1.4 L','1.5 L','1.6 L'], 'Ford|Focus': ['1.0 L','1.4 L','1.5 L','1.6 L','1.8 L','2.0 L'],
    'Ford|Mondeo': ['1.5 L','1.6 L','1.8 L','2.0 L','2.2 L','2.5 L'], 'Ford|Kuga': ['1.5 L','1.6 L','2.0 L','2.5 L'], 'Ford|EcoSport': ['1.0 L','1.5 L','2.0 L'],
    'Ford|Ranger': ['2.0 L','2.2 L','2.5 L','3.0 L','3.2 L'], 'Ford|Transit': ['2.0 L','2.2 L','2.4 L','2.5 L'],
    'Honda|Civic': ['1.0 L','1.3 L','1.4 L','1.5 L','1.6 L','1.8 L','2.0 L'], 'Honda|Accord': ['1.5 L','1.8 L','2.0 L','2.2 L','2.4 L','3.0 L','3.5 L'],
    'Honda|CR-V': ['1.5 L','1.6 L','2.0 L','2.2 L','2.4 L'], 'Honda|HR-V': ['1.5 L','1.6 L','1.8 L'], 'Honda|Jazz': ['1.2 L','1.3 L','1.4 L','1.5 L'],
    'Hyundai|i10': ['1.0 L','1.1 L','1.2 L'], 'Hyundai|i20': ['1.0 L','1.1 L','1.2 L','1.4 L'], 'Hyundai|i30': ['1.0 L','1.4 L','1.5 L','1.6 L','2.0 L'],
    'Hyundai|Accent': ['1.3 L','1.4 L','1.5 L','1.6 L'], 'Hyundai|Elantra': ['1.6 L','1.8 L','2.0 L'], 'Hyundai|Tucson': ['1.6 L','1.7 L','2.0 L','2.4 L','2.7 L'], 'Hyundai|Santa Fe': ['2.0 L','2.2 L','2.4 L','2.7 L','3.3 L','3.5 L'],
    'Isuzu|D-Max': ['1.9 L','2.5 L','3.0 L'], 'Isuzu|MU-X': ['1.9 L','2.5 L','3.0 L'], 'Isuzu|Trooper': ['2.8 L','3.0 L','3.1 L','3.2 L','3.5 L'],
    'Jeep|Cherokee': ['2.0 L','2.2 L','2.4 L','2.8 L','3.2 L','3.7 L','4.0 L'], 'Jeep|Grand Cherokee': ['3.0 L','3.6 L','4.0 L','4.7 L','5.7 L'],
    'Jeep|Compass': ['1.3 L','1.4 L','1.6 L','2.0 L','2.4 L'], 'Jeep|Renegade': ['1.0 L','1.3 L','1.4 L','1.6 L','2.0 L','2.4 L'], 'Jeep|Wrangler': ['2.0 L','2.2 L','2.8 L','3.6 L','4.0 L'],
    'Kia|Picanto': ['1.0 L','1.1 L','1.2 L'], 'Kia|Rio': ['1.0 L','1.1 L','1.2 L','1.4 L','1.5 L','1.6 L'], 'Kia|Ceed': ['1.0 L','1.4 L','1.5 L','1.6 L','2.0 L'],
    'Kia|Sportage': ['1.6 L','1.7 L','2.0 L','2.4 L','2.7 L'], 'Kia|Sorento': ['2.0 L','2.2 L','2.4 L','2.5 L','3.3 L','3.5 L'], 'Kia|Carnival': ['2.2 L','2.5 L','2.9 L','3.3 L','3.5 L'],
    'Land Rover|Defender': ['2.0 L','2.2 L','2.4 L','2.5 L','3.0 L','3.5 L','4.0 L'], 'Land Rover|Discovery': ['2.0 L','2.5 L','2.7 L','3.0 L','4.0 L','4.4 L'],
    'Land Rover|Freelander': ['1.8 L','2.0 L','2.2 L','2.5 L'], 'Land Rover|Range Rover': ['2.0 L','2.5 L','3.0 L','3.5 L','4.0 L','4.4 L','5.0 L'],
    'Land Rover|Range Rover Evoque': ['1.5 L','2.0 L','2.2 L'], 'Land Rover|Range Rover Sport': ['2.0 L','2.7 L','3.0 L','3.6 L','4.2 L','4.4 L','5.0 L'],
    'Lexus|CT': ['1.8 L'], 'Lexus|ES': ['2.0 L','2.5 L','3.0 L','3.5 L'], 'Lexus|GS': ['2.0 L','2.5 L','3.0 L','3.5 L','4.3 L','4.6 L'],
    'Lexus|IS': ['2.0 L','2.2 L','2.5 L','3.0 L','3.5 L'], 'Lexus|NX': ['2.0 L','2.5 L'], 'Lexus|RX': ['2.0 L','2.7 L','3.0 L','3.3 L','3.5 L'], 'Lexus|LX': ['4.5 L','4.6 L','4.7 L','5.7 L'],
    'Mazda|Mazda 2': ['1.3 L','1.5 L'], 'Mazda|Mazda 3': ['1.5 L','1.6 L','2.0 L','2.2 L','2.3 L','2.5 L'], 'Mazda|Mazda 6': ['1.8 L','2.0 L','2.2 L','2.3 L','2.5 L'],
    'Mazda|CX-3': ['1.5 L','2.0 L'], 'Mazda|CX-5': ['2.0 L','2.2 L','2.5 L'], 'Mazda|CX-7': ['2.2 L','2.3 L','2.5 L'], 'Mazda|CX-9': ['2.5 L','3.5 L','3.7 L'], 'Mazda|BT-50': ['2.2 L','2.5 L','3.0 L','3.2 L'],
    'Mercedes-Benz|Classe A': ['1.3 L','1.5 L','1.6 L','1.8 L','2.0 L','2.1 L'], 'Mercedes-Benz|Classe B': ['1.3 L','1.5 L','1.6 L','1.8 L','2.0 L','2.1 L'],
    'Mercedes-Benz|Classe C': ['1.5 L','1.6 L','1.8 L','2.0 L','2.1 L','2.2 L','2.5 L','3.0 L'], 'Mercedes-Benz|Classe E': ['1.8 L','2.0 L','2.1 L','2.2 L','2.7 L','3.0 L','3.2 L','3.5 L'],
    'Mercedes-Benz|Classe S': ['2.8 L','3.0 L','3.2 L','3.5 L','4.0 L','4.7 L','5.0 L','5.5 L'], 'Mercedes-Benz|CLA': ['1.3 L','1.6 L','2.0 L','2.1 L'], 'Mercedes-Benz|CLS': ['2.1 L','3.0 L','3.5 L','4.7 L','5.5 L'],
    'Mercedes-Benz|GLA': ['1.3 L','1.6 L','2.0 L','2.1 L'], 'Mercedes-Benz|GLC': ['2.0 L','2.1 L','2.2 L','3.0 L'], 'Mercedes-Benz|GLE': ['2.0 L','2.1 L','3.0 L','3.5 L','4.7 L'], 'Mercedes-Benz|GLS': ['3.0 L','4.0 L','4.7 L','5.5 L'],
    'Mercedes-Benz|Vito': ['1.6 L','2.0 L','2.1 L','2.2 L'], 'Mercedes-Benz|Sprinter': ['2.1 L','2.2 L','2.7 L','3.0 L'],
    'Mitsubishi|Colt': ['1.1 L','1.3 L','1.5 L'], 'Mitsubishi|Lancer': ['1.3 L','1.5 L','1.6 L','1.8 L','2.0 L'], 'Mitsubishi|ASX': ['1.6 L','1.8 L','2.0 L','2.2 L'],
    'Mitsubishi|Outlander': ['2.0 L','2.2 L','2.4 L','3.0 L'], 'Mitsubishi|Pajero': ['2.5 L','2.8 L','3.0 L','3.2 L','3.5 L','3.8 L'], 'Mitsubishi|L200': ['2.4 L','2.5 L','2.8 L'],
    'Nissan|Micra': ['0.9 L','1.0 L','1.2 L','1.3 L','1.4 L','1.5 L','1.6 L'], 'Nissan|Juke': ['1.0 L','1.2 L','1.5 L','1.6 L'], 'Nissan|Qashqai': ['1.2 L','1.3 L','1.5 L','1.6 L','2.0 L'],
    'Nissan|X-Trail': ['1.3 L','1.6 L','1.7 L','2.0 L','2.2 L','2.5 L'], 'Nissan|Pathfinder': ['2.5 L','3.0 L','3.5 L','4.0 L'], 'Nissan|Patrol': ['2.8 L','3.0 L','4.2 L','4.5 L','4.8 L','5.6 L'],
    'Nissan|Navara': ['2.3 L','2.5 L','3.0 L'], 'Nissan|Primastar': ['1.6 L','2.0 L','2.5 L'],
    'Opel|Corsa': ['1.0 L','1.2 L','1.3 L','1.4 L','1.5 L','1.6 L','1.7 L'], 'Opel|Astra': ['1.0 L','1.2 L','1.3 L','1.4 L','1.5 L','1.6 L','1.7 L','1.8 L','1.9 L','2.0 L'],
    'Opel|Insignia': ['1.4 L','1.5 L','1.6 L','2.0 L','2.8 L'], 'Opel|Meriva': ['1.3 L','1.4 L','1.6 L','1.7 L'], 'Opel|Zafira': ['1.4 L','1.6 L','1.7 L','1.8 L','1.9 L','2.0 L','2.2 L'],
    'Opel|Mokka': ['1.2 L','1.4 L','1.5 L','1.6 L','1.7 L'], 'Opel|Vivaro': ['1.6 L','1.9 L','2.0 L','2.5 L'],
    'Peugeot|108': ['1.0 L','1.2 L'], 'Peugeot|206': ['1.1 L','1.4 L','1.6 L','1.9 L','2.0 L'], 'Peugeot|207': ['1.4 L','1.6 L'], 'Peugeot|208': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L'],
    'Peugeot|307': ['1.4 L','1.6 L','2.0 L'], 'Peugeot|308': ['1.2 L','1.5 L','1.6 L','2.0 L'], 'Peugeot|407': ['1.6 L','1.8 L','2.0 L','2.2 L','2.7 L','3.0 L'],
    'Peugeot|508': ['1.2 L','1.5 L','1.6 L','2.0 L','2.2 L'], 'Peugeot|2008': ['1.2 L','1.5 L','1.6 L'], 'Peugeot|3008': ['1.2 L','1.5 L','1.6 L','2.0 L'], 'Peugeot|5008': ['1.2 L','1.5 L','1.6 L','2.0 L'],
    'Peugeot|Partner': ['1.2 L','1.5 L','1.6 L','1.9 L','2.0 L'], 'Peugeot|Expert': ['1.6 L','2.0 L'], 'Peugeot|Boxer': ['2.0 L','2.2 L','2.5 L','2.8 L','3.0 L'],
    'Renault|Twingo': ['0.9 L','1.0 L','1.2 L','1.6 L'], 'Renault|Clio': ['0.9 L','1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','2.0 L'], 'Renault|Mégane': ['1.2 L','1.3 L','1.4 L','1.5 L','1.6 L','1.9 L','2.0 L'],
    'Renault|Laguna': ['1.5 L','1.6 L','1.8 L','1.9 L','2.0 L','2.2 L','3.0 L'], 'Renault|Scénic': ['1.2 L','1.3 L','1.4 L','1.5 L','1.6 L','1.9 L','2.0 L'], 'Renault|Captur': ['0.9 L','1.0 L','1.2 L','1.3 L','1.5 L','1.6 L'],
    'Renault|Kadjar': ['1.2 L','1.3 L','1.5 L','1.6 L','1.7 L'], 'Renault|Koleos': ['1.6 L','1.7 L','2.0 L','2.5 L'], 'Renault|Kangoo': ['1.2 L','1.3 L','1.4 L','1.5 L','1.6 L','1.9 L'],
    'Renault|Trafic': ['1.6 L','1.9 L','2.0 L','2.5 L'], 'Renault|Master': ['2.3 L','2.5 L','2.8 L','3.0 L'],
    'Seat|Ibiza': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','1.9 L','2.0 L'], 'Seat|Leon': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','1.8 L','1.9 L','2.0 L'],
    'Seat|Toledo': ['1.2 L','1.4 L','1.6 L','1.8 L','1.9 L','2.0 L'], 'Seat|Altea': ['1.2 L','1.4 L','1.6 L','1.8 L','1.9 L','2.0 L'], 'Seat|Ateca': ['1.0 L','1.4 L','1.5 L','1.6 L','2.0 L'],
    'Škoda|Fabia': ['1.0 L','1.2 L','1.4 L','1.6 L','1.9 L','2.0 L'], 'Škoda|Octavia': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','1.8 L','1.9 L','2.0 L'],
    'Škoda|Superb': ['1.4 L','1.5 L','1.6 L','1.8 L','1.9 L','2.0 L','2.5 L','2.8 L','3.6 L'], 'Škoda|Karoq': ['1.0 L','1.5 L','1.6 L','2.0 L'], 'Škoda|Kodiaq': ['1.4 L','1.5 L','2.0 L'],
    'Subaru|Impreza': ['1.5 L','1.6 L','2.0 L','2.5 L'], 'Subaru|Legacy': ['2.0 L','2.5 L','3.0 L','3.6 L'], 'Subaru|Forester': ['2.0 L','2.5 L'], 'Subaru|Outback': ['2.0 L','2.5 L','3.0 L','3.6 L'], 'Subaru|XV': ['1.6 L','2.0 L'],
    'Suzuki|Alto': ['0.8 L','1.0 L','1.1 L'], 'Suzuki|Swift': ['1.0 L','1.2 L','1.3 L','1.4 L','1.5 L','1.6 L'], 'Suzuki|Vitara': ['1.0 L','1.4 L','1.6 L','1.9 L','2.0 L'],
    'Suzuki|Grand Vitara': ['1.6 L','1.9 L','2.0 L','2.4 L','2.5 L','2.7 L','3.2 L'], 'Suzuki|Jimny': ['1.3 L','1.5 L'], 'Suzuki|SX4': ['1.5 L','1.6 L','1.9 L','2.0 L'],
    'Toyota|Aygo': ['1.0 L','1.2 L'], 'Toyota|Yaris': ['1.0 L','1.3 L','1.4 L','1.5 L','1.8 L'], 'Toyota|Corolla': ['1.2 L','1.3 L','1.4 L','1.5 L','1.6 L','1.8 L','2.0 L'],
    'Toyota|Avensis': ['1.6 L','1.8 L','2.0 L','2.2 L','2.4 L'], 'Toyota|Camry': ['2.0 L','2.4 L','2.5 L','3.0 L','3.5 L'], 'Toyota|RAV4': ['1.8 L','2.0 L','2.2 L','2.4 L','2.5 L'],
    'Toyota|Land Cruiser': ['2.4 L','2.8 L','3.0 L','4.0 L','4.2 L','4.5 L','4.6 L','4.7 L'], 'Toyota|Prado': ['2.7 L','2.8 L','3.0 L','3.4 L','4.0 L'], 'Toyota|Fortuner': ['2.4 L','2.7 L','2.8 L','3.0 L','4.0 L'],
    'Toyota|Hilux': ['2.0 L','2.4 L','2.5 L','2.7 L','2.8 L','3.0 L','4.0 L'], 'Toyota|Hiace': ['2.0 L','2.4 L','2.5 L','2.7 L','2.8 L','3.0 L'],
    'Volkswagen|Polo': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','1.9 L','2.0 L'], 'Volkswagen|Golf': ['1.0 L','1.2 L','1.4 L','1.5 L','1.6 L','1.8 L','1.9 L','2.0 L','2.3 L','2.5 L','2.8 L','3.2 L'],
    'Volkswagen|Passat': ['1.4 L','1.5 L','1.6 L','1.8 L','1.9 L','2.0 L','2.3 L','2.5 L','2.8 L','3.2 L','3.6 L'], 'Volkswagen|Touran': ['1.2 L','1.4 L','1.5 L','1.6 L','1.9 L','2.0 L'],
    'Volkswagen|Tiguan': ['1.4 L','1.5 L','2.0 L'], 'Volkswagen|Touareg': ['2.5 L','3.0 L','3.2 L','3.6 L','4.2 L','5.0 L'], 'Volkswagen|Caddy': ['1.0 L','1.2 L','1.4 L','1.6 L','1.9 L','2.0 L'], 'Volkswagen|Transporter': ['1.9 L','2.0 L','2.4 L','2.5 L','3.2 L'],
    'Volvo|S40': ['1.6 L','1.8 L','1.9 L','2.0 L','2.4 L','2.5 L'], 'Volvo|S60': ['1.5 L','1.6 L','2.0 L','2.4 L','2.5 L','3.0 L'], 'Volvo|S80': ['1.6 L','2.0 L','2.4 L','2.5 L','2.9 L','3.0 L','3.2 L','4.4 L'],
    'Volvo|V40': ['1.5 L','1.6 L','2.0 L'], 'Volvo|V60': ['1.5 L','1.6 L','2.0 L','2.4 L'], 'Volvo|XC40': ['1.5 L','2.0 L'], 'Volvo|XC60': ['2.0 L','2.4 L','2.5 L','3.0 L'], 'Volvo|XC90': ['2.0 L','2.4 L','2.5 L','2.9 L','3.2 L','4.4 L'],
  };

  List<String> _motorizationOptionsForCar() {
    if (_selectedCarBrand == null || _selectedCarModel == null) return <String>[];
    if (_selectedCarModel == 'Autre') return const ['Autre motorisation'];
    final key = '$_selectedCarBrand|$_selectedCarModel';
    final values = _carMotorizationsByModel[key] ?? const <String>[];
    return [...values, 'Autre motorisation'];
  }

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

  bool get _isCar => _selectedCategory == 'Voitures';
  bool get _isTruck => _selectedCategory == 'Camions';

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
        label: _isCar || _isTruck ? 'Énergie' : 'Carburant',
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
    if (_isCar) {
      final models = _selectedCarBrand == null
          ? <String>[]
          : (_carModelsByBrand[_selectedCarBrand] ?? <String>[]);
      final motorizationOptions = _motorizationOptionsForCar();

      return [
        DropdownButtonFormField<String>(
          value: _selectedCarBrand,
          isExpanded: true,
          decoration: _decoration(label: 'Marque'),
          items: _carModelsByBrand.keys
              .map((brand) => DropdownMenuItem(value: brand, child: Text(brand)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCarBrand = value;
              _selectedCarModel = null;
              _selectedMotorization = null;
              _brandController.text = value ?? '';
              _modelController.clear();
            });
          },
        ),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedCarModel,
          isExpanded: true,
          decoration: _decoration(label: 'Modèle'),
          items: models
              .map((model) => DropdownMenuItem(value: model, child: Text(model)))
              .toList(),
          onChanged: _selectedCarBrand == null
              ? null
              : (value) {
                  setState(() {
                    _selectedCarModel = value;
                    _selectedMotorization = null;
                    _modelController.text = value ?? '';
                  });
                },
        ),
        _space(),
        _textField(
          controller: _yearController,
          label: 'Année-Modèle',
          number: true,
        ),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedMotorization,
          isExpanded: true,
          decoration: _decoration(label: 'Motorisation'),
          items: motorizationOptions
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: _selectedCarModel == null
              ? null
              : (value) => setState(() => _selectedMotorization = value),
        ),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedVehicleType,
          isExpanded: true,
          decoration: _decoration(label: 'Type de véhicule'),
          items: _vehicleTypes
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (value) => setState(() => _selectedVehicleType = value),
        ),
        _space(),
        _fuelField(),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedTransmission,
          isExpanded: true,
          decoration: _decoration(label: 'Boîte de vitesse'),
          items: _transmissions
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (value) => setState(() => _selectedTransmission = value),
        ),
        _space(),
        _textField(
          controller: _mileageController,
          label: 'Kilométrage',
          hint: 'Ex : 85000',
          number: true,
        ),
        _space(),
        _conditionField(),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedDoorCount,
          isExpanded: true,
          decoration: _decoration(label: 'Nombre de portes'),
          items: _carDoorCounts
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (value) => setState(() => _selectedDoorCount = value),
        ),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedSeatCount,
          isExpanded: true,
          decoration: _decoration(label: 'Nombre de places'),
          items: _carSeatCounts
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (value) => setState(() => _selectedSeatCount = value),
        ),
      ];
    }

    if (_isTruck) {
      return [
        _textField(controller: _brandController, label: 'Marque'),
        _space(),
        _textField(controller: _modelController, label: 'Modèle'),
        _space(),
        _textField(controller: _yearController, label: 'Année', number: true),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedMotorization,
          isExpanded: true,
          decoration: _decoration(label: 'Motorisation'),
          items: _motorizations
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (value) => setState(() => _selectedMotorization = value),
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
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedSeatCount,
          isExpanded: true,
          decoration: _decoration(label: 'Nombre de places'),
          items: _truckSeatCounts
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (value) => setState(() => _selectedSeatCount = value),
        ),
      ];
    }

    if (_isVehicle) {
      return [
        _textField(
          controller: _brandController,
          label: 'Marque',
          hint: 'Ex : Toyota',
        ),
        _space(),
        _textField(controller: _modelController, label: 'Modèle'),
        _space(),
        _textField(controller: _yearController, label: 'Année', number: true),
        _space(),
        DropdownButtonFormField<String>(
          value: _selectedMotorization,
          isExpanded: true,
          decoration: _decoration(label: 'Motorisation'),
          items: _motorizations
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (value) => setState(() => _selectedMotorization = value),
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
    _mileageController.clear();
    _usageHoursController.clear();
    _consoleNameController.clear();
    _gameNameController.clear();

    _selectedFuel = null;
    _selectedCondition = null;
    _selectedItemType = null;
    _selectedConsole = null;
    _selectedCarBrand = null;
    _selectedCarModel = null;
    _selectedVehicleType = null;
    _selectedTransmission = null;
    _selectedMotorization = null;
    _selectedDoorCount = null;
    _selectedSeatCount = null;
  }

  bool _validateSpecificFields() {
    if (_isCar) {
      if (_selectedCarBrand == null || _selectedCarModel == null) {
        _showMessage('Veuillez choisir la marque et le modèle.');
        return false;
      }
      if (int.tryParse(_yearController.text.trim()) == null) {
        _showMessage('Veuillez saisir une année-modèle valide.');
        return false;
      }
      if (_selectedMotorization == null) {
        _showMessage('Veuillez choisir la motorisation.');
        return false;
      }
      if (_selectedVehicleType == null) {
        _showMessage('Veuillez choisir le type de véhicule.');
        return false;
      }
      if (_selectedFuel == null) {
        _showMessage('Veuillez choisir l’énergie.');
        return false;
      }
      if (_selectedTransmission == null) {
        _showMessage('Veuillez choisir la boîte de vitesse.');
        return false;
      }
      if (int.tryParse(_mileageController.text.trim()) == null) {
        _showMessage('Veuillez saisir le kilométrage.');
        return false;
      }
      if (_selectedCondition == null) {
        _showMessage('Veuillez choisir l’état du véhicule.');
        return false;
      }
      if (_selectedDoorCount == null) {
        _showMessage('Veuillez choisir le nombre de portes.');
        return false;
      }
      if (_selectedSeatCount == null) {
        _showMessage('Veuillez choisir le nombre de places.');
        return false;
      }
      return true;
    }

    if (_isTruck) {
      if (_brandController.text.trim().isEmpty ||
          _modelController.text.trim().isEmpty ||
          int.tryParse(_yearController.text.trim()) == null ||
          _selectedMotorization == null ||
          _selectedFuel == null ||
          int.tryParse(_mileageController.text.trim()) == null ||
          _selectedCondition == null ||
          _selectedSeatCount == null) {
        _showMessage('Veuillez compléter les informations du camion.');
        return false;
      }
      return true;
    }

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

      if (_selectedMotorization == null) {
        _showMessage(
          'Veuillez choisir la motorisation.',
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
          motorization: _selectedMotorization ?? '',
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
          vehicleType: _selectedVehicleType ?? '',
          transmission: _selectedTransmission ?? '',
          doorCount: int.tryParse(_selectedDoorCount ?? ''),
          seatCount: int.tryParse(_selectedSeatCount ?? ''),
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
  final String motorization;
  final String fuelType;
  final int? mileage;
  final String itemCondition;
  final String itemType;
  final String compatibleConsole;
  final int? usageHours;
  final String consoleName;
  final String gameName;
  final String pricingType;
  final String vehicleType;
  final String transmission;
  final int? doorCount;
  final int? seatCount;

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
    required this.motorization,
    required this.fuelType,
    required this.mileage,
    required this.itemCondition,
    required this.itemType,
    required this.compatibleConsole,
    required this.usageHours,
    required this.consoleName,
    required this.gameName,
    required this.pricingType,
    required this.vehicleType,
    required this.transmission,
    required this.doorCount,
    required this.seatCount,
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
        await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                ),
                title: const Text(
                  'Choisir dans la galerie',
                ),
                onTap: () =>
                    Navigator.pop(
                  context,
                  ImageSource.gallery,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                ),
                title: const Text(
                  'Prendre une photo',
                ),
                onTap: () =>
                    Navigator.pop(
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
    if (_image == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReviewAdScreen(
          title: widget.title,
          price: widget.price,
          city: widget.city,
          district:
              widget.district,
          description:
              widget.description,
          imagePath: _image!.path,
          family: widget.family,
          category: widget.category,
          brand: widget.brand,
          model: widget.model,
          manufactureYear:
              widget.manufactureYear,
          motorization:
              widget.motorization,
          fuelType:
              widget.fuelType,
          mileage:
              widget.mileage,
          itemCondition:
              widget.itemCondition,
          itemType:
              widget.itemType,
          compatibleConsole:
              widget.compatibleConsole,
          usageHours:
              widget.usageHours,
          consoleName:
              widget.consoleName,
          gameName:
              widget.gameName,
          pricingType:
              widget.pricingType,
          vehicleType: widget.vehicleType,
          transmission: widget.transmission,
          doorCount: widget.doorCount,
          seatCount: widget.seatCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une photo',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Container(
                height: 300,
                decoration:
                    BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  child: Image.file(
                    File(_image!.path),
                    fit: BoxFit.contain,
                  ),
                ),
              )
            else
              Container(
                height: 220,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .add_photo_alternate_outlined,
                  size: 60,
                ),
              ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed:
                  _chooseImage,
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

            FilledButton(
              onPressed:
                  _image == null
                      ? null
                      : _continueToReview,
              child: const Text(
                'Continuer',
              ),
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
  final String motorization;
  final String fuelType;
  final int? mileage;
  final String itemCondition;
  final String itemType;
  final String compatibleConsole;
  final int? usageHours;
  final String consoleName;
  final String gameName;
  final String pricingType;
  final String vehicleType;
  final String transmission;
  final int? doorCount;
  final int? seatCount;

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
    required this.motorization,
    required this.fuelType,
    required this.mileage,
    required this.itemCondition,
    required this.itemType,
    required this.compatibleConsole,
    required this.usageHours,
    required this.consoleName,
    required this.gameName,
    required this.pricingType,
    required this.vehicleType,
    required this.transmission,
    required this.doorCount,
    required this.seatCount,
  });

  @override
  State<ReviewAdScreen> createState() =>
      _ReviewAdScreenState();
}

class _ReviewAdScreenState
    extends State<ReviewAdScreen> {
  bool _isPublishing = false;

  String get _displayPrice {
    if (widget.family ==
            'Prestations de services' &&
        widget.pricingType ==
            'Sur devis') {
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
      final supabase =
          Supabase.instance.client;

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Vous devez être connecté pour publier.',
        );
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

      final data =
          <String, dynamic>{
        'title':
            widget.title.trim(),
        'price':
            widget.price.trim(),
        'city':
            widget.city.trim(),
        'district':
            widget.district.trim(),
        'description':
            widget.description.trim(),
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
        'brand':
            widget.brand.isEmpty
                ? null
                : widget.brand,
        'model':
            widget.model.isEmpty
                ? null
                : widget.model,
        'manufacture_year':
            widget.manufactureYear,
        'motorization':
            widget.motorization.isEmpty ? null : widget.motorization,
        'fuel_type':
            widget.fuelType.isEmpty
                ? null
                : widget.fuelType,
        'mileage':
            widget.mileage,
        'item_condition':
            widget.itemCondition.isEmpty
                ? null
                : widget.itemCondition,
        'item_type':
            widget.itemType.isEmpty
                ? null
                : widget.itemType,
        'compatible_console':
            widget.compatibleConsole.isEmpty
                ? null
                : widget.compatibleConsole,
        'usage_hours':
            widget.usageHours,
        'pricing_type':
            widget.pricingType,
        'vehicle_type':
            widget.vehicleType.isEmpty ? null : widget.vehicleType,
        'transmission':
            widget.transmission.isEmpty ? null : widget.transmission,
        'door_count':
            widget.doorCount,
        'seat_count':
            widget.seatCount,
      };

      if (widget.itemType ==
          'Console') {
        data['brand'] =
            widget.consoleName;
      }

      if (widget.itemType ==
          'Jeu') {
        data['model'] =
            widget.gameName;
      }

      await supabase
          .from('annonces')
          .insert(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Annonce publiée avec succès',
          ),
        ),
      );

      // ==================================================
      // APRÈS PUBLICATION :
      // ACCUEIL + SUPPRESSION DES ÉCRANS DE CRÉATION
      // ==================================================

      final navigation =
          context.read<NavigationViewModel>();

      // Sélectionne l'accueil dans la barre de navigation.
      navigation.onDestinationSelected(0);

      // Supprime Photo et Vérification de la pile.
      // Le bouton Retour ne ramène donc pas
      // sur l'annonce qui vient d'être publiée.
      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

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

  Widget _row(
    String label,
    String value,
  ) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        '$label : $value',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vérifier l’annonce',
        ),
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
              decoration:
                  BoxDecoration(
                color: Colors.black,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
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

            const SizedBox(height: 10),

            Text(
              _displayPrice,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _row(
              'Famille',
              widget.family,
            ),

            _row(
              'Catégorie',
              widget.category,
            ),

            if (widget.brand.isNotEmpty)
              _row(
                'Marque',
                widget.brand,
              ),

            if (widget.model.isNotEmpty)
              _row(
                'Modèle',
                widget.model,
              ),

            if (widget.manufactureYear !=
                null)
              _row(
                'Année',
                widget.manufactureYear
                    .toString(),
              ),

            if (widget.motorization.isNotEmpty)
              _row(
                'Motorisation',
                widget.motorization,
              ),

            if (widget
                .fuelType.isNotEmpty)
              _row(
                'Carburant',
                widget.fuelType,
              ),

            if (widget.vehicleType.isNotEmpty)
              _row('Type de véhicule', widget.vehicleType),

            if (widget.transmission.isNotEmpty)
              _row('Boîte de vitesse', widget.transmission),

            if (widget.mileage != null)
              _row(
                'Kilométrage',
                '${widget.mileage} km',
              ),

            if (widget.doorCount != null)
              _row('Nombre de portes', widget.doorCount.toString()),

            if (widget.seatCount != null)
              _row('Nombre de places', widget.seatCount.toString()),

            if (widget
                .itemType.isNotEmpty)
              _row(
                'Type',
                widget.itemType,
              ),

            if (widget
                .compatibleConsole
                .isNotEmpty)
              _row(
                'Console compatible',
                widget
                    .compatibleConsole,
              ),

            if (widget.usageHours !=
                null)
              _row(
                'Heures d’utilisation',
                '${widget.usageHours} h',
              ),

            if (widget
                .itemCondition
                .isNotEmpty)
              _row(
                'État',
                widget.itemCondition,
              ),

            if (widget.family ==
                'Prestations de services')
              _row(
                'Tarification',
                widget.pricingType,
              ),

            _row(
              'Ville',
              widget.city,
            ),

            _row(
              'Commune',
              widget.district,
            ),

            const SizedBox(height: 12),

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
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed:
                    _isPublishing
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}