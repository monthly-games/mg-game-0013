// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameDataAdapter extends TypeAdapter<GameData> {
  @override
  final int typeId = 0;

  @override
  GameData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameData(
      gold: fields[0] as int,
      crystal: fields[1] as int,
      battleTickets: fields[2] as int,
      leaguePoints: fields[3] as int,
      currentTier: fields[4] as String,
      wins: fields[5] as int,
      losses: fields[6] as int,
      myTeam: (fields[7] as List).cast<SavedHeroData>(),
      heroInventory: (fields[8] as List).cast<SavedHeroData>(),
      seasonNumber: fields[9] as int,
      seasonEndDate: fields[10] as DateTime,
      lastPlayed: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GameData obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.gold)
      ..writeByte(1)
      ..write(obj.crystal)
      ..writeByte(2)
      ..write(obj.battleTickets)
      ..writeByte(3)
      ..write(obj.leaguePoints)
      ..writeByte(4)
      ..write(obj.currentTier)
      ..writeByte(5)
      ..write(obj.wins)
      ..writeByte(6)
      ..write(obj.losses)
      ..writeByte(7)
      ..write(obj.myTeam)
      ..writeByte(8)
      ..write(obj.heroInventory)
      ..writeByte(9)
      ..write(obj.seasonNumber)
      ..writeByte(10)
      ..write(obj.seasonEndDate)
      ..writeByte(11)
      ..write(obj.lastPlayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavedHeroDataAdapter extends TypeAdapter<SavedHeroData> {
  @override
  final int typeId = 1;

  @override
  SavedHeroData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedHeroData(
      id: fields[0] as String,
      name: fields[1] as String,
      job: fields[2] as String,
      rarity: fields[3] as String,
      cost: fields[4] as int,
      level: fields[5] as int,
      exp: fields[6] as double,
      maxHp: fields[7] as double,
      attack: fields[8] as double,
      defense: fields[9] as double,
      critRate: fields[10] as double,
      critDamage: fields[11] as double,
      range: fields[12] as double,
      speed: fields[13] as double,
      skillId: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedHeroData obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.job)
      ..writeByte(3)
      ..write(obj.rarity)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.exp)
      ..writeByte(7)
      ..write(obj.maxHp)
      ..writeByte(8)
      ..write(obj.attack)
      ..writeByte(9)
      ..write(obj.defense)
      ..writeByte(10)
      ..write(obj.critRate)
      ..writeByte(11)
      ..write(obj.critDamage)
      ..writeByte(12)
      ..write(obj.range)
      ..writeByte(13)
      ..write(obj.speed)
      ..writeByte(14)
      ..write(obj.skillId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedHeroDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
