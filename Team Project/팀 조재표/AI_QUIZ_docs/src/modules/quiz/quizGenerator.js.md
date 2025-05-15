# modules/quiz/quizGenerator.js

---
type: file
path: src/modules/quiz/quizGenerator.js
language: javascript
---

## 목적
텍스트 청크에서 다양한 형태의 퀴즈 문항을 LLM을 활용하여 자동 생성하는 서비스입니다. 객관식, OX, 주관식 등 여러 퀴즈 타입을 지원합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `QuizGenerator` | 클래스 | 퀴즈 생성 총괄 관리 |
| `generateQuiz()` | 메서드 | 텍스트 청크에서 퀴즈 생성 |
| `generateQuizFromQuery()` | 메서드 | 검색 쿼리 기반 퀴즈 생성 |
| `selectRelevantChunks()` | 프라이빗 메서드 | 퀴즈 생성용 청크 선택 |
| `generateQuestionFromChunk()` | 프라이빗 메서드 | 개별 청크에서 문항 생성 |
| `buildQuestionPrompt()` | 프라이빗 메서드 | LLM 프롬프트 구성 |
| `validateQuestions()` | 프라이빗 메서드 | 생성된 퀴즈 검증 |

## 의존성
- [[src/utils/logger.js]]: 로깅 기능
- [[src/modules/quiz/llmService.js]]: LLM 텍스트 생성
- [[src/modules/embedding/embeddingService.js]]: 의미적 청크 선택

## 데이터 흐름
```mermaid
graph LR
    A[텍스트 청크] --> B[청크 선택]
    B --> C[프롬프트 생성]
    C --> D[LLM 호출]
    D --> E[응답 파싱]
    E --> F[문항 검증]
    F --> G[최종 퀴즈]
```

## 지원하는 퀴즈 타입

### 1. 객관식 (Multiple Choice)
- 4개 선택지 (A, B, C, D)
- 정답 1개, 오답 3개
- 해설 포함

### 2. 참/거짓 (True/False)
- 진술문 형태
- 정답과 해설 제공

### 3. 단답형 (Short Answer)
- 1-3문장 답변 요구
- 예시 답안 제공

### 4. 빈칸 채우기 (Fill in Blank)
- 핵심 단어/구문 제거
- 문맥 기반 답안

## 코드 예시
```javascript
const quizGenerator = new QuizGenerator();

// 기본 퀴즈 생성
const quiz = await quizGenerator.generateQuiz(embeddedChunks, {
  quizType: 'multiple_choice',
  difficulty: 'medium',
  questionCount: 5,
  topicFocus: 'machine learning'
});

// 검색 기반 퀴즈 생성
const queryQuiz = await quizGenerator.generateQuizFromQuery(
  "What is neural network?",
  embeddedChunks,
  { questionCount: 3, difficulty: 'easy' }
);

// 퀴즈 통계
const stats = quizGenerator.getQuizStats(quiz);
console.log('생성된 문항 수:', stats.totalQuestions);
console.log('타입별 분포:', stats.byType);
```

## 퀴즈 옵션
```javascript
{
  quizType: 'multiple_choice' | 'true_false' | 'short_answer' | 'fill_in_blank',
  difficulty: 'easy' | 'medium' | 'hard',
  questionCount: 5,
  topicFocus: '특정 주제',
  customInstructions: '추가 지시사항'
}
```

## 생성된 퀴즈 구조
```javascript
{
  id: "quiz_1715692800000_abc123",
  type: "multiple_choice",
  difficulty: "medium",
  question: "What is machine learning?",
  options: [
    "A) A subset of artificial intelligence",
    "B) A programming language",
    "C) A database system",
    "D) A web framework"
  ],
  correctAnswer: "A",
  explanation: "Machine learning is indeed a subset of AI...",
  sourceChunk: "chunk_0_1715692800000",
  pageNumber: 1,
  createdAt: "2025-05-14T10:30:45.123Z"
}
```

## 청크 선택 전략

### 1. 주제 기반 선택
- 의미적 임베딩 유사도 사용
- 특정 주제에 관련된 청크 우선 선택

### 2. 분산 선택
- 문서 전체에 걸친 균등한 분포
- 다양한 내용 커버

### 3. 품질 기반 선택
- 충분한 정보를 담은 청크 우선
- 토큰 수 및 문맥 완성도 고려

## LLM 프롬프트 전략

### 구조화된 프롬프트
```
Based on the following text, generate a {difficulty} difficulty {type} question.

Text:
{chunk_content}

Create a multiple choice question with 4 options...

Format your response as JSON:
{
  "question": "Your question here",
  "options": [...],
  "correctAnswer": "B",
  "explanation": "..."
}
```

### 타입별 맞춤 프롬프트
- 각 퀴즈 타입에 최적화된 프롬프트
- JSON 형태의 구조화된 응답 요구
- 해설 포함 필수

## 검증 체계

### 1. 기본 검증
- 필수 필드 존재 확인
- 적절한 길이 검증
- 객관식 선택지 수 확인

### 2. LLM 기반 검증 (선택적)
- 문항 명확성 검사
- 정답 정확성 확인
- 오답 타당성 검토

## 성능 고려사항
- 청크 선택 최적화로 API 호출 최소화
- 배치 처리로 동시 생성 지원
- 실패한 문항은 로그 기록 후 스킵

## 잠재적 개선사항
- 문항 난이도 자동 평가
- 기존 문항과의 중복 방지
- 다국어 퀴즈 지원
- 이미지/도표 기반 문항 생성
