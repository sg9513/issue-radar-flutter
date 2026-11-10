# 📡 이슈 레이더 (Issue Radar Native App)

> **5대 플랫폼(GitHub, Reddit, X, Facebook, Google) 실시간 이슈 수집 및 심층 분석 네이티브 앱**  
> Flutter 기반 순수 모바일 네이티브 구현체

---

## 🎨 디자인 및 UI 특징
- **옵시디언 딥 다크 테마**: 장시간 집중해서 텍스트를 읽어도 피로감이 없는 딥 네이비(`0xFF0B0F19`) 배경
- **플랫폼 시그니처 뱃지 & 네온 글로우**: 깃허브, 레딧, X, 페이스북, 구글 고유 브랜드 액센트
- **인터랙티브 카드 & 모달 시트**: 탭 시 햅틱 피드백과 함께 부드럽게 펼쳐지는 **발단 배경 · 커뮤니티 반응 · 핵심 시사점** 3단 심층 분석
- **실시간 검색 & 필터 칩**: 플랫폼별 탭 전환 및 키워드 즉시 검색

---

## 📂 프로젝트 구조
```
issue-radar-flutter/
├── lib/
│   ├── main.dart                      # 앱 진입점 및 시스템 테마 설정
│   ├── models/
│   │   └── issue_item.dart            # 플랫폼별 데이터 모델 및 채널 열거형
│   ├── services/
│   │   └── issue_service.dart         # 실시간 이슈 수집, 검색, 북마크 상태 관리
│   ├── theme/
│   │   └── app_theme.dart             # 다크 글래스모피즘 컬러 및 타이포그래피
│   ├── widgets/
│   │   ├── issue_card.dart            # 피드 카드 컴포넌트
│   │   └── detail_sheet.dart          # 3단계 심층 분석 바텀 시트
│   └── screens/
│       ├── home_screen.dart           # 메인 피드, 검색, 필터 뷰
│       └── settings_screen.dart       # 푸시 알림 및 동기화 설정 센터
├── .github/workflows/
│   └── build-flutter-apk.yml          # 깃허브 액션 원클릭 APK 자동 빌드
└── pubspec.yaml                       # 의존성 설정
```

---

## 🚀 빠른 시작 (Local Run & Build)

### 1. 로컬 실행
```bash
# 의존성 설치
flutter pub get

# 앱 실행 (연결된 안드로이드 기기 또는 에뮬레이터)
flutter run
```

### 2. 로컬에서 APK 추출
```bash
flutter build apk --release
# 빌드 완료 파일 위치: build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚡ 깃허브 원클릭 자동 빌드 (무설치 APK 다운로드)
PC에 Flutter SDK나 Android Studio를 설치할 필요 없이 깃허브 서버에서 APK를 생성합니다.
1. `issue-radar-flutter` 프로젝트를 깃허브 저장소에 Push
2. 깃허브 저장소의 **Actions** 탭으로 이동
3. `Build Flutter APK` 워크플로우가 자동으로 실행되어 2분 만에 완료
4. 생성된 **Artifacts**에서 `IssueRadar-Flutter-Release-APK`를 다운로드하여 스마트폰에 바로 설치!
