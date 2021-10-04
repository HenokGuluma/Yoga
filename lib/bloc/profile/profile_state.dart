part of 'profile_bloc.dart';

@immutable
class ProfileState {
  final bool isPhotoEmpty;
  final bool isNameEmpty;
  final bool isAgeEmpty;
  final bool isGenderEmpty;
  final bool isInterestedInEmpty;
  final bool isLocationEmpty;
  final bool isFailure;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isBioEmpty;
  final bool isVerifiedEmpty;

  bool get isFormValid =>
      isPhotoEmpty &&
          isBioEmpty &&
          isVerifiedEmpty&&
      isNameEmpty &&
      isAgeEmpty &&
      isGenderEmpty &&
      isInterestedInEmpty;

  ProfileState({
    @required this.isPhotoEmpty,
    @required this.isNameEmpty,
    @required this.isBioEmpty,
    @required this.isAgeEmpty,
    @required this.isGenderEmpty,
    @required this.isInterestedInEmpty,
    @required this.isLocationEmpty,
    @required this.isVerifiedEmpty,
    @required this.isFailure,
    @required this.isSubmitting,
    @required this.isSuccess,
  });

  //Initial State
  factory ProfileState.empty() {
    return ProfileState(
      isPhotoEmpty: false,
      isFailure: false,
      isSuccess: false,
      isBioEmpty: false,
      isSubmitting: false,
      isNameEmpty: false,
      isVerifiedEmpty: false,
      isAgeEmpty: false,
      isGenderEmpty: false,
      isInterestedInEmpty: false,
      isLocationEmpty: false,
    );
  }

  //Submitting state
  factory ProfileState.loading() {
    return ProfileState(
      isPhotoEmpty: false,
      isFailure: false,
      isBioEmpty: false,
      isSuccess: false,
      isSubmitting: true,
      isVerifiedEmpty: false,
      isNameEmpty: false,
      isAgeEmpty: false,
      isGenderEmpty: false,
      isInterestedInEmpty: false,
      isLocationEmpty: false,
    );
  }

  //Failed state
  factory ProfileState.failure() {
    return ProfileState(
      isPhotoEmpty: false,
      isBioEmpty: false,
      isFailure: true,
      isSuccess: false,
      isSubmitting: false,
      isNameEmpty: false,
      isAgeEmpty: false,
      isVerifiedEmpty: false,
      isGenderEmpty: false,
      isInterestedInEmpty: false,
      isLocationEmpty: false,
    );
  }

  //Success state
  factory ProfileState.success() {
    return ProfileState(
      isPhotoEmpty: false,
      isBioEmpty: false,
      isFailure: false,
      isSuccess: true,
      isSubmitting: false,
      isVerifiedEmpty: false,
      isNameEmpty: false,
      isAgeEmpty: false,
      isGenderEmpty: false,
      isInterestedInEmpty: false,
      isLocationEmpty: false,
    );
  }

  ProfileState update({
    bool isPhotoEmpty,
    bool isBioEmpty,
    bool isNameEmpty,
    bool isAgeEmpty,
    bool isGenderEmpty,
    bool isInterestedInEmpty,
    bool isLocationEmpty,
    bool isVerifiedEmpty
  }) {
    return copyWith(
      isFailure: false,
      isSuccess: false,
      isBioEmpty: false,
      isSubmitting: false,

      isPhotoEmpty: isPhotoEmpty,
      isNameEmpty: isNameEmpty,
      isAgeEmpty: isAgeEmpty,
      isGenderEmpty: isGenderEmpty,
      isInterestedInEmpty: isInterestedInEmpty,
      isLocationEmpty: isLocationEmpty,
      isVerifiedEmpty: isVerifiedEmpty
    );
  }

  ProfileState copyWith({
    bool isPhotoEmpty,
    bool isNameEmpty,
    bool isBioEmpty,
    bool isAgeEmpty,
    bool isGenderEmpty,
    bool isInterestedInEmpty,
    bool isLocationEmpty,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
    bool isVerifiedEmpty,
  }) {
    return ProfileState(
      isPhotoEmpty: isPhotoEmpty ?? this.isPhotoEmpty,
      isBioEmpty: isBioEmpty ?? this.isBioEmpty,
      isNameEmpty: isNameEmpty ?? this.isNameEmpty,
      isLocationEmpty: isLocationEmpty ?? this.isLocationEmpty,
      isInterestedInEmpty: isInterestedInEmpty ?? this.isInterestedInEmpty,
      isGenderEmpty: isGenderEmpty ?? this.isGenderEmpty,
      isAgeEmpty: isAgeEmpty ?? this.isAgeEmpty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      isVerifiedEmpty: isVerifiedEmpty ?? this.isVerifiedEmpty
    );
  }
}
