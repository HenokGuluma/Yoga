part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class NameChanged extends ProfileEvent {
  final String name;

  NameChanged({@required this.name});

  @override
  List<Object> get props => [name];
}

class BioChanged extends ProfileEvent {
  final String bio;

  BioChanged({@required this.bio});

  @override
  List<Object> get props => [bio];
}

class PhotoChanged extends ProfileEvent {
  final File photo;

  PhotoChanged({@required this.photo});

  @override
  List<Object> get props => [photo];
}

class AgeChanged extends ProfileEvent {
  final DateTime age;

  AgeChanged({@required this.age});

  @override
  List<Object> get props => [age];
}

class GenderChanged extends ProfileEvent {
  final String gender;

  GenderChanged({@required this.gender});

  @override
  List<Object> get props => [gender];
}

class InterestedInChanged extends ProfileEvent {
  final String interestedIn;

  InterestedInChanged({@required this.interestedIn});

  @override
  List<Object> get props => [interestedIn];
}

class LocationChanged extends ProfileEvent {
  final GeoPoint location;

  LocationChanged({@required this.location});

  @override
  List<Object> get props => [location];
}
class VerifiedChanged extends ProfileEvent {
  final bool verified;

  VerifiedChanged({@required this.verified});

  @override
  List<Object> get props => [verified];
}

class Submitted extends ProfileEvent {
  final String name, gender, interestedIn, bio;
  final DateTime age;
  final GeoPoint location;
  final File photo;
  final bool verified;

  Submitted(
      {@required this.name,
        @required this.bio,
      @required this.gender,
      @required this.interestedIn,
      @required this.age,
      @required this.location,
      @required this.photo,
      @required this.verified});

  @override
  List<Object> get props => [location, name, age, gender, interestedIn, photo, bio, verified];
}
