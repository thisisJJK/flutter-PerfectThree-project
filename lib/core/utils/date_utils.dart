// 날짜 관련 유틸리티 함수들을 모아놓은 클래스입니다.
class DateUtils {
  // DateTime 객체에서 시간 정보를 제거하고 날짜만 남깁니다. (YYYY-MM-DD)
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // 두 날짜가 동일한 날짜인지 확인합니다. (시간 무시)
  static bool isSameDay(DateTime date1, DateTime date2) {
    return dateOnly(date1).isAtSameMomentAs(dateOnly(date2));
  }
  //두 날짜 차이
  static int differenceDay(DateTime date1, DateTime date2) {
    return dateOnly(date1).difference(dateOnly(date2)).inDays;
  }
}
