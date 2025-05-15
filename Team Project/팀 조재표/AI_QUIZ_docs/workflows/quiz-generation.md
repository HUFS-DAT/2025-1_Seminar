# 퀴즈 생성 워크플로우

---
type: feature
---

## 설명
처리된 텍스트 청크를 기반으로 AI가 퀴즈 문항을 생성하는 과정입니다. (현재 미구현 상태)

## 예상 관련 파일
1. [[src/modules/quiz/quizGenerator.js]]: 퀴즈 생성 로직 (미구현)
2. [[src/modules/quiz/llmService.js]]: LLM 서비스 인터페이스 (미구현)
3. [[src/modules/embedding/embeddingService.js]]: 텍스트 임베딩 서비스 (미구현)

## 예상 실행 순서
1. **청크 선택**
   - 사용자 요청 또는 자동 선택
   - 임베딩 기반 관련 청크 검색

2. **퀴즈 타입 결정**
   - 객관식, 주관식, O/X 등
   - 난이도 설정

3. **LLM 프롬프트 생성**
   - 청크 내용 기반 프롬프트 구성
   - 퀴즈 타입별 템플릿 적용

4. **퀴즈 생성**
   - LLM API 호출
   - 응답 파싱 및 검증

5. **후처리**
   - 퀴즈 품질 검증
   - 메타데이터 추가
   - 데이터베이스 저장

## 주요 데이터 구조 (예상)
```javascript
// 퀴즈 문항
{
  id: "quiz_123",
  question: "질문 내용",
  type: "multiple_choice",
  options: ["A", "B", "C", "D"],
  correctAnswer: "B",
  explanation: "정답 해설",
  difficulty: "medium",
  sourceChunk: "chunk_0_1715692800000"
}
```

## 예외 처리 (예상)
- LLM 응답 형식 오류
- 부적절한 퀴즈 내용 생성
- API 호출 제한 초과
- 청크 정보 부족
