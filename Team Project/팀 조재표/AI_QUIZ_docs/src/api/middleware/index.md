# api/middleware

---
type: directory
path: src/api/middleware/
---

## 목적
HTTP 요청/응답을 가로채서 전처리, 검증, 인증 등을 수행하는 미들웨어들을 포함하는 디렉토리입니다.

## 주요 파일
현재 구현된 파일 없음

## 구현 예정 파일
| 파일 | 역할 |
|------|------|
| [[src/api/middleware/authMiddleware.js]] | 인증/인가 미들웨어 |
| [[src/api/middleware/validationMiddleware.js]] | 요청 검증 미들웨어 |
| [[src/api/middleware/rateLimitMiddleware.js]] | 요청 제한 미들웨어 |
| [[src/api/middleware/errorMiddleware.js]] | 에러 처리 미들웨어 |
| [[src/api/middleware/loggingMiddleware.js]] | 요청 로깅 미들웨어 |

## 하위 디렉토리
없음

## 현재 적용된 미들웨어

### 1. CORS 미들웨어
```javascript
// src/index.js에 구현
app.use(cors({
  origin: Config.CORS_ORIGINS,
  credentials: true
}));
```

### 2. Body 파싱 미들웨어
```javascript
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
```

### 3. 파일 업로드 미들웨어 (Multer)
```javascript
const upload = multer({ 
  storage,
  limits: { fileSize: 50 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only PDF files are allowed'));
    }
  }
});
```

### 4. 로깅 미들웨어
```javascript
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });
  next();
});
```

## 구현 예정 미들웨어

### 인증 미들웨어
```javascript
export const authenticate = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    const decoded = verifyJWT(token);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};
```

### 검증 미들웨어
```javascript
export const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: error.details 
      });
    }
    next();
  };
};
```

### Rate Limiting 미들웨어
```javascript
import rateLimit from 'express-rate-limit';

export const apiRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15분
  max: 100, // 요청 제한
  message: {
    error: 'Too many requests, please try again later'
  }
});

export const uploadRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 업로드는 더 엄격하게
  message: {
    error: 'Too many upload requests'
  }
});
```

### 에러 처리 미들웨어
```javascript
export const errorHandler = (error, req, res, next) => {
  logger.error('Unhandled error', error);
  
  // Multer 에러
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large' });
    }
  }
  
  // 기본 에러 응답
  res.status(error.status || 500).json({
    error: error.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
};
```

## 미들웨어 적용 순서

```javascript
// 1. 보안 미들웨어
app.use(helmet());
app.use(cors());

// 2. 파싱 미들웨어  
app.use(express.json());
app.use(express.urlencoded());

// 3. 로깅 미들웨어
app.use(loggingMiddleware);

// 4. Rate limiting
app.use('/api', apiRateLimit);

// 5. 라우트별 미들웨어
app.use('/api/documents/upload', uploadRateLimit, upload.single('pdf'));

// 6. 에러 미들웨어 (마지막)
app.use(errorHandler);
```

## 모듈화 계획

### 현재 상태
- 모든 미들웨어가 `src/index.js`에 인라인으로 구현
- 재사용성과 테스트 가능성 부족

### 개선 방향
1. 각 미들웨어를 별도 파일로 분리
2. 미들웨어 팩토리 패턴 적용
3. 테스트 가능한 순수 함수로 구현
4. 설정 가능한 미들웨어 옵션

## 관련 파일
- [[src/index.js]]: 현재 미들웨어 구현
- [[src/utils/logger.js]]: 로깅 유틸리티
- [[src/core/config.js]]: 미들웨어 설정
