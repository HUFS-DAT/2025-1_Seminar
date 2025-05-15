# pdfExtractor.js

---
type: file
path: src/modules/preprocessing/pdfExtractor.js
language: javascript
---

## 목적
PDF 파일에서 텍스트를 추출하는 클래스입니다. 기본적으로 pdf-parse를 사용하고, 추출 품질이 낮은 경우 OCR(Tesseract)을 대체 방법으로 사용합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `PDFExtractor` | 클래스 | PDF 텍스트 추출 관리 |
| `extractText()` | 메서드 | 메인 텍스트 추출 함수 |
| `extractWithPdfParse()` | 프라이빗 메서드 | pdf-parse 라이브러리 사용 추출 |
| `extractWithOCR()` | 프라이빗 메서드 | Tesseract OCR 사용 추출 |
| `needsOCR()` | 프라이빗 메서드 | OCR 필요 여부 판단 |

## 의존성
- `pdf-parse`: PDF 텍스트 직접 추출
- `child_process`: OCR 프로세스 실행
- `fs`: 파일 시스템 접근
- [[src/utils/logger.js]]: 로깅 기능 (가정)

## 데이터 흐름
PDF 파일 → pdf-parse 추출 → 품질 검사 → (필요시) OCR 추출 → 결과 반환

## 주요 알고리즘/패턴

### 이중 추출 전략
1. **1차 추출**: pdf-parse로 빠른 텍스트 추출
2. **품질 평가**: `needsOCR()` 함수로 텍스트 품질 판단
3. **2차 추출**: 품질이 낮으면 OCR로 대체

### OCR 처리 파이프라인
1. PDF → 이미지 변환 (pdftoppm)
2. 각 이미지 → Tesseract OCR
3. 결과 텍스트 합성
4. 임시 파일 정리

## 코드 예시
```javascript
const extractor = new PDFExtractor();

// 기본 사용법
const result = await extractor.extractText('document.pdf');
console.log(result.text);
console.log(result.pageCount);
console.log(result.method); // 'pdf-parse' 또는 'ocr'

// 결과 구조
{
  text: "추출된 텍스트...",
  pageCount: 10,
  metadata: { /* PDF 메타데이터 */ },
  method: "pdf-parse"
}
```

## 텍스트 품질 판단 기준
- 텍스트 길이 100자 미만
- 특수문자 비율 50% 초과
- 실제 단어 비율 50% 미만

## 외부 의존성
- **pdftoppm** (poppler-utils): PDF to Image 변환
- **tesseract**: OCR 엔진

## 잠재적 문제점
- 외부 프로그램(pdftoppm, tesseract) 설치 필요
- OCR 처리 시간이 오래 걸릴 수 있음
- 임시 이미지 파일 생성으로 인한 디스크 사용량 증가
- 동시 처리 시 리소스 경합 가능
