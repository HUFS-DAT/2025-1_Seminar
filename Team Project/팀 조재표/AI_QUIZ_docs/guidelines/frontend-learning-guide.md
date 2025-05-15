# AI Quiz Frontend 학습 가이드라인

---
type: guide
---

## 🎯 목적
AI Quiz Frontend 개발을 위한 체계적인 학습 경로와 개발 전략을 제시합니다.

## 📋 개발 상태
**현재 상태**: 프론트엔드 미구현
**권장 기술 스택**: React.js + TypeScript + Tailwind CSS

## 🏗 추천 프론트엔드 아키텍처

### 기술 스택
```javascript
// 추천 스택
- Framework: React 18+
- Language: TypeScript
- State Management: Zustand 또는 Redux Toolkit
- Styling: Tailwind CSS
- API Client: React Query + Axios
- Routing: React Router v6
- UI Components: Headless UI 또는 Radix UI
- Form Handling: React Hook Form
- Build Tool: Vite
```

## 📚 단계별 학습 순서

### 1단계: 백엔드 API 이해 (1시간)
**목표**: 백엔드 API 구조와 데이터 흐름 파악

**필수 문서**:
1. [[api/documents.md]] - 문서 업로드/관리 API
2. [[api/quiz.md]] - 퀴즈 생성 API
3. [[api/search.md]] - 검색 API
4. [[project.md]] - 전체 시스템 이해

**실습 과제**:
```bash
# API 엔드포인트 테스트
curl http://localhost:5000/health
curl -X POST http://localhost:5000/api/documents/upload -F "pdf=@test.pdf"
```

### 2단계: 프로젝트 설정 (30분)
**목표**: React 프로젝트 초기 설정

```bash
# 프로젝트 생성
npm create vite@latest ai-quiz-frontend -- --template react-ts
cd ai-quiz-frontend
npm install

# 추가 의존성 설치
npm install @tanstack/react-query axios
npm install @headlessui/react @heroicons/react
npm install react-hook-form @hookform/resolvers yup
npm install zustand
npm install tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 3단계: 컴포넌트 구조 설계 (45분)
**목표**: 애플리케이션 컴포넌트 구조 정의

```
src/
├── components/         # 재사용 컴포넌트
│   ├── common/        # 공통 컴포넌트
│   ├── document/      # 문서 관련 컴포넌트
│   ├── quiz/          # 퀴즈 관련 컴포넌트
│   └── search/        # 검색 관련 컴포넌트
├── pages/             # 페이지 컴포넌트
├── hooks/             # 커스텀 훅
├── services/          # API 서비스
├── store/             # 상태 관리
├── types/             # TypeScript 타입 정의
└── utils/             # 유틸리티 함수
```

### 4단계: API 클라이언트 구현 (1시간)
**목표**: 백엔드 API와 통신하는 클라이언트 구현

```typescript
// services/api.ts
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 문서 관련 API
export const documentAPI = {
  upload: (file: File) => {
    const formData = new FormData();
    formData.append('pdf', file);
    return apiClient.post('/api/documents/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
  
  getDocument: (id: string) => 
    apiClient.get(`/api/documents/${id}`),
    
  getChunks: (id: string) => 
    apiClient.get(`/api/documents/${id}/chunks`),
};

// 퀴즈 관련 API
export const quizAPI = {
  generate: (data: GenerateQuizRequest) =>
    apiClient.post('/api/quiz/generate', data),
    
  generateFromQuery: (data: GenerateFromQueryRequest) =>
    apiClient.post('/api/quiz/generate-from-query', data),
};

// 검색 관련 API
export const searchAPI = {
  semantic: (query: string, options?: SearchOptions) =>
    apiClient.post('/api/search/semantic', { query, ...options }),
};
```

### 5단계: 상태 관리 구현 (45분)
**목표**: Zustand를 사용한 전역 상태 관리

```typescript
// store/documentStore.ts
import { create } from 'zustand';

interface DocumentState {
  documents: Document[];
  currentDocument: Document | null;
  isUploading: boolean;
  uploadProgress: number;
  
  // Actions
  uploadDocument: (file: File) => Promise<void>;
  setCurrentDocument: (doc: Document) => void;
  clearDocuments: () => void;
}

export const useDocumentStore = create<DocumentState>((set, get) => ({
  documents: [],
  currentDocument: null,
  isUploading: false,
  uploadProgress: 0,
  
  uploadDocument: async (file: File) => {
    set({ isUploading: true, uploadProgress: 0 });
    try {
      const response = await documentAPI.upload(file);
      const newDoc = response.data;
      set(state => ({
        documents: [...state.documents, newDoc],
        isUploading: false,
        uploadProgress: 100,
      }));
    } catch (error) {
      set({ isUploading: false, uploadProgress: 0 });
      throw error;
    }
  },
  
  setCurrentDocument: (doc: Document) => 
    set({ currentDocument: doc }),
    
  clearDocuments: () => 
    set({ documents: [], currentDocument: null }),
}));
```

### 6단계: 핵심 컴포넌트 구현 (2시간)

#### 6.1 문서 업로드 컴포넌트
```typescript
// components/document/DocumentUpload.tsx
import { useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { useDocumentStore } from '../../store/documentStore';

export function DocumentUpload() {
  const { uploadDocument, isUploading, uploadProgress } = useDocumentStore();
  
  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (file && file.type === 'application/pdf') {
      try {
        await uploadDocument(file);
      } catch (error) {
        console.error('Upload failed:', error);
      }
    }
  }, [uploadDocument]);
  
  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'application/pdf': ['.pdf'] },
    multiple: false,
  });
  
  return (
    <div
      {...getRootProps()}
      className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer
        ${isDragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'}
        ${isUploading ? 'opacity-50 cursor-not-allowed' : ''}
      `}
    >
      <input {...getInputProps()} />
      {isUploading ? (
        <div>
          <div className="mb-2">업로드 중... {uploadProgress}%</div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div 
              className="bg-blue-600 h-2 rounded-full"
              style={{ width: `${uploadProgress}%` }}
            />
          </div>
        </div>
      ) : (
        <div>
          <p className="text-lg mb-2">PDF 파일을 드래그하거나 클릭하세요</p>
          <p className="text-sm text-gray-500">최대 50MB까지 지원</p>
        </div>
      )}
    </div>
  );
}
```

#### 6.2 퀴즈 생성 컴포넌트
```typescript
// components/quiz/QuizGenerator.tsx
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useQuizStore } from '../../store/quizStore';

interface QuizGeneratorProps {
  documentId: string;
}

export function QuizGenerator({ documentId }: QuizGeneratorProps) {
  const { generateQuiz, isGenerating } = useQuizStore();
  const { register, handleSubmit, watch } = useForm({
    defaultValues: {
      quizType: 'multiple_choice',
      difficulty: 'medium',
      questionCount: 5,
      topicFocus: '',
    },
  });
  
  const onSubmit = async (data: any) => {
    try {
      await generateQuiz({ documentId, ...data });
    } catch (error) {
      console.error('Quiz generation failed:', error);
    }
  };
  
  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-1">퀴즈 타입</label>
        <select {...register('quizType')} className="w-full border rounded px-3 py-2">
          <option value="multiple_choice">객관식</option>
          <option value="true_false">참/거짓</option>
          <option value="short_answer">단답형</option>
          <option value="fill_in_blank">빈칸 채우기</option>
        </select>
      </div>
      
      <div>
        <label className="block text-sm font-medium mb-1">난이도</label>
        <select {...register('difficulty')} className="w-full border rounded px-3 py-2">
          <option value="easy">쉬움</option>
          <option value="medium">보통</option>
          <option value="hard">어려움</option>
        </select>
      </div>
      
      <div>
        <label className="block text-sm font-medium mb-1">문항 수</label>
        <input
          type="number"
          min="1"
          max="20"
          {...register('questionCount')}
          className="w-full border rounded px-3 py-2"
        />
      </div>
      
      <div>
        <label className="block text-sm font-medium mb-1">주제 집중 (선택)</label>
        <input
          type="text"
          placeholder="예: 머신러닝, 딥러닝"
          {...register('topicFocus')}
          className="w-full border rounded px-3 py-2"
        />
      </div>
      
      <button
        type="submit"
        disabled={isGenerating}
        className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 disabled:opacity-50"
      >
        {isGenerating ? '퀴즈 생성 중...' : '퀴즈 생성'}
      </button>
    </form>
  );
}
```

#### 6.3 퀴즈 표시 컴포넌트
```typescript
// components/quiz/QuizDisplay.tsx
import { useState } from 'react';
import { Quiz, Question } from '../../types/quiz';

interface QuizDisplayProps {
  quiz: Quiz;
  onSubmit: (answers: Record<string, any>) => void;
}

export function QuizDisplay({ quiz, onSubmit }: QuizDisplayProps) {
  const [answers, setAnswers] = useState<Record<string, any>>({});
  const [currentQuestion, setCurrentQuestion] = useState(0);
  
  const handleAnswer = (questionId: string, answer: any) => {
    setAnswers(prev => ({ ...prev, [questionId]: answer }));
  };
  
  const handleNext = () => {
    if (currentQuestion < quiz.questions.length - 1) {
      setCurrentQuestion(prev => prev + 1);
    }
  };
  
  const handlePrevious = () => {
    if (currentQuestion > 0) {
      setCurrentQuestion(prev => prev - 1);
    }
  };
  
  const handleSubmit = () => {
    onSubmit(answers);
  };
  
  const question = quiz.questions[currentQuestion];
  
  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="mb-4">
        <div className="flex justify-between items-center mb-2">
          <span className="text-sm text-gray-500">
            {currentQuestion + 1} / {quiz.questions.length}
          </span>
          <span className="text-sm text-gray-500 capitalize">
            {question.difficulty} • {question.type.replace('_', ' ')}
          </span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div 
            className="bg-blue-600 h-2 rounded-full"
            style={{ width: `${((currentQuestion + 1) / quiz.questions.length) * 100}%` }}
          />
        </div>
      </div>
      
      <QuestionComponent
        question={question}
        answer={answers[question.id]}
        onAnswer={(answer) => handleAnswer(question.id, answer)}
      />
      
      <div className="flex justify-between mt-6">
        <button
          onClick={handlePrevious}
          disabled={currentQuestion === 0}
          className="px-4 py-2 border rounded disabled:opacity-50"
        >
          이전
        </button>
        
        {currentQuestion === quiz.questions.length - 1 ? (
          <button
            onClick={handleSubmit}
            className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
          >
            제출
          </button>
        ) : (
          <button
            onClick={handleNext}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            다음
          </button>
        )}
      </div>
    </div>
  );
}
```

### 7단계: 검색 기능 구현 (45분)
```typescript
// components/search/SemanticSearch.tsx
import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { searchAPI } from '../../services/api';

export function SemanticSearch() {
  const [query, setQuery] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  
  const { data: results, isLoading, error } = useQuery({
    queryKey: ['search', searchTerm],
    queryFn: () => searchAPI.semantic(searchTerm),
    enabled: !!searchTerm,
  });
  
  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      setSearchTerm(query.trim());
    }
  };
  
  return (
    <div className="w-full max-w-2xl mx-auto">
      <form onSubmit={handleSearch} className="mb-6">
        <div className="flex gap-2">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="검색어를 입력하세요..."
            className="flex-1 border rounded px-3 py-2"
          />
          <button
            type="submit"
            disabled={isLoading}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
          >
            {isLoading ? '검색 중...' : '검색'}
          </button>
        </div>
      </form>
      
      {error && (
        <div className="bg-red-50 border border-red-200 rounded p-4 mb-4">
          검색 중 오류가 발생했습니다.
        </div>
      )}
      
      {results && (
        <SearchResults results={results.data.results} />
      )}
    </div>
  );
}
```

### 8단계: 라우팅 및 네비게이션 (30분)
```typescript
// App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient();

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <div className="min-h-screen bg-gray-50">
          <Navigation />
          <main className="container mx-auto px-4 py-8">
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/documents" element={<DocumentsPage />} />
              <Route path="/documents/:id" element={<DocumentDetailPage />} />
              <Route path="/quiz/:id" element={<QuizPage />} />
              <Route path="/search" element={<SearchPage />} />
            </Routes>
          </main>
        </div>
      </BrowserRouter>
    </QueryClientProvider>
  );
}
```

## 🎨 UI/UX 고려사항

### 디자인 원칙
1. **사용성 우선**: 직관적이고 쉬운 인터페이스
2. **반응형 디자인**: 모바일/태블릿/데스크톱 지원
3. **접근성**: WCAG 가이드라인 준수
4. **성능**: 빠른 로딩과 반응성

### 주요 UI 패턴
```typescript
// 로딩 상태
<LoadingSpinner />

// 에러 상태
<ErrorBoundary fallback={<ErrorDisplay />}>
  <Component />
</ErrorBoundary>

// 빈 상태
<EmptyState
  icon={DocumentIcon}
  title="아직 문서가 없습니다"
  description="PDF 파일을 업로드해서 시작하세요"
  action={<UploadButton />}
/>
```

## 📱 모바일 최적화

### 반응형 컴포넌트
```typescript
// 모바일 친화적 퀴즈 인터페이스
export function MobileQuizView() {
  return (
    <div className="px-4 py-6">
      {/* 모바일에서 큰 터치 영역 */}
      <div className="grid gap-4">
        {options.map((option, index) => (
          <button
            key={index}
            className="w-full p-4 text-left border rounded-lg text-lg
                     hover:bg-blue-50 active:bg-blue-100"
          >
            {option}
          </button>
        ))}
      </div>
    </div>
  );
}
```

## 🧪 테스트 전략

### 단위 테스트
```typescript
// components/__tests__/QuizGenerator.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { QuizGenerator } from '../QuizGenerator';

describe('QuizGenerator', () => {
  it('renders form fields correctly', () => {
    render(<QuizGenerator documentId="test-id" />);
    
    expect(screen.getByLabelText('퀴즈 타입')).toBeInTheDocument();
    expect(screen.getByLabelText('난이도')).toBeInTheDocument();
    expect(screen.getByLabelText('문항 수')).toBeInTheDocument();
  });
  
  it('submits form with correct data', async () => {
    const mockGenerateQuiz = jest.fn();
    render(<QuizGenerator documentId="test-id" />);
    
    fireEvent.click(screen.getByText('퀴즈 생성'));
    
    expect(mockGenerateQuiz).toHaveBeenCalledWith({
      documentId: 'test-id',
      quizType: 'multiple_choice',
      difficulty: 'medium',
      questionCount: 5,
    });
  });
});
```

## 🚀 배포 및 최적화

### 빌드 최적화
```javascript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          query: ['@tanstack/react-query'],
        },
      },
    },
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
});
```

## 📊 성능 모니터링

### 웹 바이탈 측정
```typescript
// utils/analytics.ts
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

export function measureWebVitals() {
  getCLS(console.log);
  getFID(console.log);
  getFCP(console.log);
  getLCP(console.log);
  getTTFB(console.log);
}
```

## 🔄 개발 워크플로우

### 1. 컴포넌트 개발 순서
1. API 타입 정의
2. 상태 관리 구현
3. 컴포넌트 구현
4. 테스트 작성
5. 스토리북 문서화

### 2. 브랜치 전략
```bash
# 기능 브랜치
git checkout -b feature/quiz-generator
git checkout -b feature/document-upload
git checkout -b feature/search-interface
```

## 📚 추천 학습 자료

### React/TypeScript
- React 공식 문서
- TypeScript 핸드북
- React Hook Form 가이드

### 상태 관리
- Zustand 문서
- React Query 가이드

### 스타일링
- Tailwind CSS 문서
- Headless UI 컴포넌트

이 가이드라인을 따라 개발하면 AI Quiz 시스템의 완성도 높은 프론트엔드를 구축할 수 있습니다! 🎨✨
