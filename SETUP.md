# LiveNote 프로젝트 설정 가이드

## Firebase 설정

이 프로젝트는 Firebase Analytics를 사용합니다. 보안을 위해 `GoogleService-Info.plist`는 Git에 포함되지 않습니다.

### 설정 방법

1. **Firebase Console 접속**: https://console.firebase.google.com/
2. **livenote-5aa4c** 프로젝트 선택
3. **⚙️ 프로젝트 설정** > **일반** 탭
4. **내 앱** 섹션에서 iOS 앱 선택
5. **GoogleService-Info.plist 다운로드** 클릭
6. 다운로드한 파일을 `LiveNote/GoogleService-Info.plist` 위치에 복사
7. Xcode에서 프로젝트에 추가:
   - 파일을 Xcode로 드래그
   - "Copy items if needed" 체크
   - Target "LiveNote" 체크

### 빌드 & 실행

```bash
# Xcode에서
1. Clean Build: Shift + Cmd + K
2. Build: Cmd + B
3. Run: Cmd + R
```

Console에 `✅ Firebase 초기화 완료` 로그가 나오면 성공!
