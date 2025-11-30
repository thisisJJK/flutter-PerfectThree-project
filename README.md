# Perfect Three

**3일 반복 성공 구조를 통해 포기하지 않는 습관을 만드는 Flutter 앱**

## 📱 프로젝트 소개

Perfect Three는 3일 연속으로 목표를 달성하는 것을 반복하여 습관을 형성하는 모바일 앱입니다. 단순하지만 효과적인 방법으로 지속 가능한 습관 형성을 도와줍니다.

### 주요 기능

- ✅ **3일 도전 시스템**: 3일 연속 목표 달성을 통해 습관 형성
- 📊 **진행 상황 추적**: 진행중인 목표와 완료된 루틴을 분리하여 관리
- 📈 **통계 확인**: 전체 통계 및 월별 통계로 성취도 확인
- 🎨 **다크 모드 지원**: 라이트/다크 테마 전환 가능
- 💾 **로컬 저장소**: Hive를 사용한 빠르고 안정적인 데이터 저장
- 🏷️ **카테고리 관리**: 목표를 카테고리별로 분류하여 관리

## 🛠️ 기술 스택

- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Riverpod**: 상태 관리
- **GoRouter**: 화면 라우팅
- **Hive**: 로컬 NoSQL 데이터베이스
- **Google Mobile Ads**: 광고 통합

## 📦 설치 방법

### 필수 요구사항

- Flutter SDK (3.9.2 이상)
- Dart SDK
- Android Studio / Xcode (플랫폼별)

### 설치 단계

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd perfect_three
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **코드 생성 (Riverpod, Hive)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **앱 실행**
   ```bash
   flutter run
   ```

## 🚀 빌드

### Android
```bash
flutter build apk --release
# 또는
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📁 프로젝트 구조

```
lib/
├── core/                    # 핵심 기능
│   ├── routes/             # 라우팅 설정
│   └── theme/              # 테마 및 스타일
├── data/                   # 데이터 레이어
│   ├── models/            # 데이터 모델
│   └── repositories/      # 데이터 저장소
├── features/              # 기능별 모듈
│   ├── goals/            # 목표 관리 기능
│   ├── settings/         # 설정 화면
│   └── splash/           # 스플래시 화면
└── shared/               # 공유 유틸리티
    ├── ads/              # 광고 관련
    └── utils/            # 공통 유틸리티
```

## 🔧 주요 의존성

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # 상태 관리
  go_router: ^17.0.0            # 라우팅
  hive: ^2.2.3                  # 로컬 데이터베이스
  hive_flutter: ^1.1.0
  google_mobile_ads: ^6.0.0     # 광고
  package_info_plus: ^8.1.1     # 앱 정보
```

## 📝 라이선스

이 프로젝트의 라이선스는 앱 내 설정 화면에서 확인할 수 있습니다.

## 🤝 기여

이슈 리포트나 개선 제안은 언제든 환영합니다!

## 📄 라이선스

이 프로젝트는 개인 사용 목적으로 개발되었습니다.
