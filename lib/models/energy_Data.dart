class EnergyData {
  final double current;
  final double power;
  final double energy;
  final DateTime timestamp;

  EnergyData({
    required this.current,
    required this.power,
    required this.energy,
    required this.timestamp,
  });

  factory EnergyData.fromJson(Map<String, dynamic> json) {
    return EnergyData(
      current: json['current']?.toDouble() ?? 0.0,
      power: json['power']?.toDouble() ?? 0.0,
      energy: json['energy']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class EnergyStats {
  final double avgPower;
  final double maxPower;
  final double totalEnergy;

  EnergyStats({
    required this.avgPower,
    required this.maxPower,
    required this.totalEnergy,
  });

  factory EnergyStats.fromJson(Map<String, dynamic> json) {
    return EnergyStats(
      avgPower: json['avg_power']?.toDouble() ?? 0.0,
      maxPower: json['max_power']?.toDouble() ?? 0.0,
      totalEnergy: json['total_energy']?.toDouble() ?? 0.0,
    );
  }
}