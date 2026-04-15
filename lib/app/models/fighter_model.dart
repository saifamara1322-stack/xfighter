class Fighter {
  final String id;
  final String userId;
  final int weight;
  final String weightClass;
  final int height;
  final int reach;
  final FightRecord record;
  final String style;
  final String gym;
  final String? coachId;
  final bool verified;
  final String? profileImageUrl;
  final String? bio;
  final String? nationality;
  final DateTime? birthDate;
  
  Fighter({
    required this.id,
    required this.userId,
    required this.weight,
    required this.weightClass,
    required this.height,
    required this.reach,
    required this.record,
    required this.style,
    required this.gym,
    this.coachId,
    required this.verified,
    this.profileImageUrl,
    this.bio,
    this.nationality,
    this.birthDate,
  });
  
  factory Fighter.fromJson(Map<String, dynamic> json) {
    return Fighter(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      weight: json['weight'],
      weightClass: json['weightClass'],
      height: json['height'],
      reach: json['reach'],
      record: FightRecord.fromJson(json['record']),
      style: json['style'],
      gym: json['gym'],
      coachId: json['coachId']?.toString(),
      verified: json['verified'] ?? false,
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      nationality: json['nationality'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'weightClass': weightClass,
      'height': height,
      'reach': reach,
      'record': record.toJson(),
      'style': style,
      'gym': gym,
      'coachId': coachId,
      'verified': verified,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'nationality': nationality,
      'birthDate': birthDate?.toIso8601String(),
    };
  }
  
  int get wins => record.wins;
  int get losses => record.losses;
  int get draws => record.draws;
  int get totalFights => wins + losses + draws;
  double get winPercentage => totalFights > 0 ? (wins / totalFights) * 100 : 0;
  int get knockouts => record.knockouts;
  int get submissions => record.submissions;
  int get decisions => record.decisions;
  double get knockoutPercentage => totalFights > 0 ? (knockouts / totalFights) * 100 : 0;
  
  String get winLossRecord => '$wins - $losses - $draws';
}

class FightRecord {
  final int wins;
  final int losses;
  final int draws;
  final int knockouts;
  final int submissions;
  final int decisions;
  
  FightRecord({
    required this.wins,
    required this.losses,
    required this.draws,
    required this.knockouts,
    required this.submissions,
    required this.decisions,
  });
  
  factory FightRecord.fromJson(Map<String, dynamic> json) {
    return FightRecord(
      wins: json['wins'],
      losses: json['losses'],
      draws: json['draws'],
      knockouts: json['knockouts'],
      submissions: json['submissions'],
      decisions: json['decisions'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'knockouts': knockouts,
      'submissions': submissions,
      'decisions': decisions,
    };
  }
}

enum WeightClass {
  flyweight(57, 'Flyweight', 57),
  bantamweight(61, 'Bantamweight', 61),
  featherweight(66, 'Featherweight', 66),
  lightweight(70, 'Lightweight', 70),
  welterweight(77, 'Welterweight', 77),
  middleweight(84, 'Middleweight', 84),
  lightHeavyweight(93, 'Light Heavyweight', 93),
  heavyweight(120, 'Heavyweight', 120);
  
  final int minWeight;
  final String displayName;
  final int maxWeight;
  
  const WeightClass(this.minWeight, this.displayName, this.maxWeight);
  
  static WeightClass fromWeight(int weight) {
    for (var wc in WeightClass.values) {
      if (weight <= wc.maxWeight) {
        return wc;
      }
    }
    return WeightClass.heavyweight;
  }
  
  static List<String> get allDisplayNames {
    return WeightClass.values.map((wc) => wc.displayName).toList();
  }
}