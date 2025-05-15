# PDF 문서 처리 워크플로우

---
type: feature
---

## 설명
PDF 파일을 업로드하여 텍스트를 추출하고, 정제 및 청킹을 통해 임베딩 가능한 형태로 변환하는 전체 처리 과정입니다.

## 관련 파일
1. [[src/modules/preprocessing/pdfExtractor.js]]: PDF에서 텍스트 추출
2. [[src/modules/preprocessing/textProcessor.js]]: 텍스트 정제 및 교정
3. [[src/modules/preprocessing/textChunker.js]]: 텍스트 청킹 및 최적화
4. [[src/core/config.js]]: 처리 관련 설정값

## 실행 순서
1. **PDF 업로드 및 저장**
   - 클라이언트에서 PDF 파일 업로드
   - 서버의 업로드 디렉토리에 임시 저장

2. **텍스트 추출 (pdfExtractor)**
   - pdf-parse를 사용한 1차 추출
   - 텍스트 품질 평가
   - 필요시 OCR(Tesseract) 대체 추출

3. **텍스트 정제 (textProcessor)**
   - 기본 정규화 (공백, 특수문자 처리)
   - LLM 기반 OCR 오류 수정
   - 포맷팅 개선

4. **텍스트 청킹 (textChunker)**
   - 의미적 경계 기반 분할
   - 토큰 크기 최적화
   - 메타데이터 추가
   - LLM 기반 청크 검증

5. **결과 저장**
   - 청크 정보 데이터베이스 저장
   - 원본 파일 정리

## 주요 데이터 구조
```javascript
// PDF 추출 결과
{
  text: "추출된 전체 텍스트",
  pageCount: 10,
  metadata: { /* PDF 메타정보 */ },
  method: "pdf-parse" // or "ocr"
}

// 최종 청크 결과
[
  {
    content: "청크 내용",
    index: 0,
    tokenCount: 245,
    pageNumber: 1,
    chunkId: "chunk_0_1715692800000"
  }
]
```

## 예외 처리
- **PDF 추출 실패**: 에러 반환 및 처리 중단
- **OCR 실패**: 기본 추출 결과 사용
- **LLM 서비스 불가**: 기본 처리만 수행
- **청킹 실패**: 기본 청킹 결과 사용

## 성능 고려사항
- 큰 PDF 파일 처리 시간
- OCR 처리로 인한 지연
- LLM 호출 비용 및 시간
- 임시 파일 정리
