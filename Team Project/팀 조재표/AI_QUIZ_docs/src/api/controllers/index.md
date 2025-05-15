# api/controllers

---
type: directory
path: src/api/controllers/
---

## 목적
API 엔드포인트의 비즈니스 로직을 처리하는 컨트롤러들을 포함하는 디렉토리입니다. 각 컨트롤러는 특정 도메인의 요청을 처리합니다.

## 주요 파일
현재 구현된 파일 없음

## 구현 예정 파일
| 파일 | 역할 |
|------|------|
| [[src/api/controllers/documentController.js]] | 문서 업로드/관리 컨트롤러 |
| [[src/api/controllers/quizController.js]] | 퀴즈 생성/관리 컨트롤러 |
| [[src/api/controllers/searchController.js]] | 검색 기능 컨트롤러 |
| [[src/api/controllers/healthController.js]] | 헬스체크 컨트롤러 |

## 하위 디렉토리
없음

## 설계 패턴

### Controller 구조
```javascript
// 표준 컨트롤러 패턴
export class DocumentController {
  constructor(dependencies) {
    this.documentService = dependencies.documentService;
    this.logger = dependencies.logger;
  }

  async uploadDocument(req, res, next) {
    try {
      // 비즈니스 로직
      const result = await this.documentService.process(req.file);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }
}
```

### 의존성 주입
- 서비스 클래스 주입
- 로거 주입
- 설정 주입

### 에러 처리
- try-catch로 예외 처리
- Express error middleware로 전달
- 일관된 에러 응답 형식

## 현재 상태
현재 모든 컨트롤러 로직이 [[src/index.js]]에 통합되어 있습니다. 코드 분리와 모듈화를 위해 별도 컨트롤러 클래스로 분리하는 것이 권장됩니다.

## 관련 파일
- [[src/index.js]]: 현재 컨트롤러 로직 포함
- [[src/api/routes/index]]: 라우터 정의
- [[src/api/middleware/index]]: 미들웨어 정의
