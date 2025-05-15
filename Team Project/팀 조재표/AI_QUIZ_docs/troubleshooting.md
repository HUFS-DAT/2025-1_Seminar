# 문제해결 가이드

---
type: troubleshooting
---

## 알려진 이슈

| 증상 | 원인 | 해결방법 |
|------|------|----------|
| PDF 추출 텍스트가 깨짐 | OCR이 필요한 스캔된 PDF | `needsOCR()` 로직 확인, Tesseract 설치 확인 |
| 빈 텍스트 추출 | 이미지만 있는 PDF | OCR 경로 강제 사용, 이미지 품질 확인 |
| 청크 크기가 너무 큼/작음 | 토큰 추정 오류 | `CHUNK_CONFIG` 설정 조정 |
| LLM 교정 실패 | API 키 문제 또는 서비스 장애 | `OPENAI_API_KEY` 확인, 기본 정제만 진행 |
| 메모리 부족 | 대용량 PDF 처리 | 스트리밍 처리 구현 필요 |

## 디버깅 포인트

### PDF 추출 문제
- [[src/modules/preprocessing/pdfExtractor.js]]: `extractWithPdfParse()` 결과 확인
- 외부 도구 설치 상태: `pdftoppm --version`, `tesseract --version`

### 텍스트 정제 문제
- [[src/modules/preprocessing/textProcessor.js]]: `basicTextCleaning()` 단계별 결과 확인
- LLM 서비스 응답 로그 확인

### 청킹 문제
- [[src/modules/preprocessing/textChunker.js]]: `estimateTokenCount()` 정확도 확인
- 토큰 설정값과 실제 결과 비교

### 설정 문제
- [[src/core/config.js]]: 환경 변수 로딩 확인
- `Config.validate()` 호출 결과 확인

## 로그 분석
```javascript
// 로그 레벨별 확인사항
// INFO: 처리 진행 상황
// ERROR: 실패한 단계와 원인
// DEBUG: 상세 처리 과정 (구현 예정)
```

## 성능 최적화
1. **PDF 처리 최적화**
   - 소형 파일은 메모리 처리
   - 대형 파일은 스트리밍 처리

2. **LLM 호출 최적화**
   - 배치 처리로 API 호출 최소화
   - 캐싱 전략 구현

3. **메모리 관리**
   - 임시 파일 자동 정리
   - 청크 처리 후 메모리 해제

## 모니터링 권장사항
- 처리 시간 메트릭
- 에러율 추적
- 리소스 사용량 모니터링
- LLM 토큰 사용량 추적
