# textProcessor.js

---
type: file
path: src/modules/preprocessing/textProcessor.js
language: javascript
---

## 목적
PDF에서 추출된 원본 텍스트를 정제하고, LLM을 활용하여 OCR 오류 수정 및 텍스트 품질 향상을 수행하는 클래스입니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `TextProcessor` | 클래스 | 텍스트 처리 및 정제 관리 |
| `processText()` | 메서드 | 메인 텍스트 처리 함수 |
| `basicTextCleaning()` | 프라이빗 메서드 | 기본적인 텍스트 정규화 |
| `llmTextCorrection()` | 프라이빗 메서드 | LLM 기반 텍스트 교정 |
| `generateCorrectionPrompt()` | 프라이빗 메서드 | LLM 프롬프트 생성 |

## 의존성
- [[src/utils/logger.js]]: 로깅 기능
- [[src/modules/quiz/llmService.js]]: LLM 서비스 (가정)

## 데이터 흐름
원본 텍스트 → 기본 정제 → LLM 교정 (가능한 경우) → 정제된 텍스트

## 주요 알고리즘/패턴

### 이중 처리 전략
1. **기본 정제**: 정규 표현식 기반 텍스트 정규화
2. **LLM 교정**: OCR 오류 수정 및 품질 개선

### 기본 정제 규칙
- 제어 문자 제거 (폼 피드 등)
- 줄바꿈 정규화
- 과도한 공백 정리
- 불릿 포인트 표준화
- OCR 오류 패턴 수정

## 코드 예시
```javascript
const processor = new TextProcessor();

// 기본 사용법
const cleanedText = await processor.processText(rawText);

// 기본 정제만 수행 (LLM 서비스 없는 경우)
const basicCleaned = processor.basicTextCleaning(rawText);
```

## 기본 정제 처리 내용

### 문자 정규화
- 폼 피드 문자 (`\f`) 제거
- 캐리지 리턴 정규화 (`\r\n` → `\n`)
- 탭과 공백 정규화

### 포맷팅 개선
- 과도한 빈 줄 정리 (3개 이상 → 2개)
- 불릿 포인트 표준화 (`•` → `- `)
- 구두점 주변 공백 조정

### OCR 오류 수정
- 분리된 숫자 복원 (`1 . 5` → `1.5`)
- 대소문자 사이 누락된 공백 추가

## LLM 교정 처리
- 텍스트를 2000자 단위로 분할하여 처리
- 프롬프트를 통해 OCR 오류 및 포맷 이슈 수정 요청
- LLM 서비스 실패 시 기본 정제 결과 반환

## 에러 처리
- LLM 서비스 불가 시 기본 정제만 수행
- 교정 실패 시 원본 텍스트 반환
- 로깅을 통한 에러 추적

## 잠재적 문제점
- LLM 토큰 제한으로 인한 긴 텍스트 처리 어려움
- LLM 호출 비용 및 응답 시간
- 정규 표현식 규칙의 한계 (언어별 특성 고려 부족)
- 청크 단위 처리 시 문맥 손실 가능성
