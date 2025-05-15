# textChunker.js

---
type: file
path: src/modules/preprocessing/textChunker.js
language: javascript
---

## 목적
정제된 텍스트를 의미적으로 일관성 있는 청크로 분할하고, 토큰 제한을 고려하여 최적화하며, LLM을 활용한 청크 검증을 수행하는 클래스입니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `TextChunker` | 클래스 | 텍스트 청킹 관리 |
| `createChunks()` | 메서드 | 메인 청킹 함수 |
| `semanticChunking()` | 프라이빗 메서드 | 의미적 경계 기반 분할 |
| `optimizeChunkSizes()` | 프라이빗 메서드 | 토큰 제한 기반 최적화 |
| `validateChunks()` | 프라이빗 메서드 | LLM 기반 청크 검증 |
| `estimateTokenCount()` | 프라이빗 메서드 | 토큰 수 추정 |

## 의존성
- [[src/utils/logger.js]]: 로깅 기능
- [[src/core/config.js]]: `CHUNK_CONFIG` 설정
- [[src/modules/quiz/llmService.js]]: LLM 서비스

## 데이터 흐름
정제된 텍스트 → 의미적 분할 → 크기 최적화 → 메타데이터 추가 → LLM 검증 → 최종 청크

## 주요 알고리즘/패턴

### 3단계 청킹 전략
1. **의미적 청킹**: 단락과 섹션 헤더 기반 분할
2. **크기 최적화**: 토큰 제한 고려한 분할/병합
3. **LLM 검증**: 의미적 일관성 검화 및 개선 제안

### 의미적 경계 탐지
- 이중 줄바꿈(`\n\n`)으로 단락 분할
- 섹션 헤더 패턴 인식:
  - 마크다운 헤더 (`#`, `##`, etc.)
  - 콜론 종료 제목 (`Title:`)
  - 번호가 있는 제목 (`1. Section`)

## 코드 예시
```javascript
const chunker = new TextChunker();

// 기본 사용법
const chunks = await chunker.createChunks(cleanedText, pageCount);

// 결과 구조
[
  {
    content: "청크 내용...",
    index: 0,
    tokenCount: 245,
    pageNumber: 1,
    chunkId: "chunk_0_1715692800000"
  },
  // ...
]
```

## 크기 최적화 로직

### 토큰 기반 처리
- **최대 토큰**: 설정값 (기본 500)
- **최소 토큰**: 설정값 (기본 50)
- **오버랩**: 청크간 중복 토큰 (기본 50)

### 크기 조정 전략
- 너무 큰 청크: 문장 단위로 분할
- 너무 작은 청크: 이전 청크와 병합
- 오버랩 처리: 이전 청크의 마지막 문장들을 다음 청크에 포함

## LLM 검증 프로세스

### 배치 처리
- 5개 청크씩 배치로 처리
- JSON 형태의 검증 결과 요청
- 병합/분할/수정 제안 수집

### 검증 기준
- 의미적 완전성 (완전한 개념 포함)
- 청크간 논리적 연결성
- 토큰 효율성

## 메타데이터 구조
```javascript
{
  content: "청크 내용",
  index: 0,              // 청크 인덱스
  tokenCount: 250,       // 추정 토큰 수
  pageNumber: 2,         // 추정 페이지 번호
  chunkId: "unique_id"   // 고유 식별자
}
```

## 토큰 추정 방식
- 단어 수 기반 근사치 (1 토큰 ≈ 0.75 단어)
- 정확한 토큰화는 아니지만 전처리 단계에서 충분한 정확도

## 잠재적 문제점
- 토큰 추정의 부정확성 (실제 토큰화와 차이)
- LLM 검증 비용과 시간
- 큰 문서의 경우 처리 시간 증가
- 언어별 특성 미반영 (영어 기준 최적화)
- 검증 결과 적용이 단순함 (현재는 로깅만)
