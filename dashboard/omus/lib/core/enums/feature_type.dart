/// Enum representing different features/amenities available at bus stops.
enum FeatureType {
  advertising,
  bench,
  bicycleParking,
  bin,
  lit,
  ramp,
  shelter,
  level,
  passengerInformationDisplaySpeechOutput,
  tactileWritingBrailleEs,
  tactilePaving,
  departuresBoard,
}

extension FeatureTypeExtension on FeatureType {
  static const Map<FeatureType, String> _featureTypeMap = {
    FeatureType.advertising: 'advertising',
    FeatureType.bench: 'bench',
    FeatureType.bicycleParking: 'bicycleParking',
    FeatureType.bin: 'bin',
    FeatureType.lit: 'lit',
    FeatureType.ramp: 'ramp',
    FeatureType.shelter: 'shelter',
    FeatureType.level: 'level',
    FeatureType.passengerInformationDisplaySpeechOutput:
        'passenger_information_display:speech_output',
    FeatureType.tactileWritingBrailleEs: 'tactile_writing:braille:es',
    FeatureType.tactilePaving: 'tactile_paving',
    FeatureType.departuresBoard: 'departures_board',
  };

  String toValue() => _featureTypeMap[this]!;

  static FeatureType fromValue(String value) =>
      _featureTypeMap.entries.firstWhere((entry) => entry.value == value).key;

  static const Map<FeatureType, String> _featureTypeSpanishMap = {
    FeatureType.advertising: 'Panel Publicidad',
    FeatureType.bench: 'Tiene Banco',
    FeatureType.bicycleParking: 'Tiene Aparcabici',
    FeatureType.bin: 'Tiene Tacho',
    FeatureType.lit: 'Iluminacion',
    FeatureType.ramp: 'Rampas Acera',
    FeatureType.shelter: 'Tiene Techo',
    FeatureType.level: 'Acceso Nivel',
    FeatureType.passengerInformationDisplaySpeechOutput: 'Guia Sonora',
    FeatureType.tactileWritingBrailleEs: 'Señal Braille',
    FeatureType.tactilePaving: 'Guia Podotactil',
    FeatureType.departuresBoard: 'Info Rutas',
  };

  String toText() => _featureTypeSpanishMap[this]!;
}
