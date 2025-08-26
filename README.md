# Medicontents Backend API

메디컨텐츠 QA 시스템의 백엔드 API 서버입니다.

## 기술 스택

- **Framework**: FastAPI
- **Python**: 3.11
- **Database**: Airtable
- **AI**: Google Gemini API
- **Deployment**: Docker

## 주요 기능

### API 엔드포인트

#### 1. 기본 엔드포인트
- `GET /`: 헬스 체크
- `GET /api/health`: 서버 상태 확인

#### 2. 로그 관리
- `POST /api/add-log`: 실시간 로그 추가
- `GET /api/get-logs/{post_id}`: 특정 Post ID의 로그 조회
- `DELETE /api/clear-logs/{post_id}`: 특정 Post ID의 로그 삭제

#### 3. 데이터 처리
- `GET /api/random-post-data`: Post Data Requests에서 랜덤 데이터 조회
- `POST /api/process-post`: Post ID로 Agent 실행 및 데이터 처리

#### 4. n8n 연동
- `POST /api/n8n-completion`: n8n 워크플로우 완료 후 호출
- `POST /api/test-webhook`: 웹훅 테스트

## 환경 변수

### 필수 환경 변수
```bash
# Airtable 설정
AIRTABLE_API_KEY=your_airtable_api_key
AIRTABLE_BASE_ID=your_airtable_base_id

# Gemini AI 설정
GEMINI_API_KEY=your_gemini_api_key

# Agent 파일 경로
AGENTS_BASE_PATH=/app/agents
```

### 선택적 환경 변수
```bash
# 서버 설정
PORT=8000
HOST=0.0.0.0

# 로깅 설정
LOG_LEVEL=INFO
```

## 설치 및 실행

### 로컬 개발

1. **의존성 설치**
```bash
pip install -r requirements.txt
```

2. **환경 변수 설정**
```bash
cp .env.example .env
# .env 파일을 편집하여 필요한 환경 변수 설정
```

3. **서버 실행**
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Docker 배포

1. **이미지 빌드**
```bash
docker build -t medicontents-backend .
```

2. **컨테이너 실행**
```bash
docker run -p 8000:8000 \
  -e AIRTABLE_API_KEY=your_key \
  -e AIRTABLE_BASE_ID=your_base_id \
  -e GEMINI_API_KEY=your_gemini_key \
  medicontents-backend
```

## Agent 시스템

### Agent 실행 순서
1. **InputAgent**: 입력 데이터 처리
2. **PlanAgent**: 콘텐츠 계획 수립
3. **TitleAgent**: 제목 생성
4. **ContentAgent**: 본문 콘텐츠 생성
5. **EvaluationAgent**: 콘텐츠 평가

### Agent 파일 구조
```
agents/
├── input_agent.py
├── plan_agent.py
├── title_agent.py
├── content_agent.py
├── evaluation_agent.py
├── run_agents.py
├── utils/
│   └── (유틸리티 파일들)
└── __pycache__/
```

## CORS 설정

프론트엔드 도메인을 허용하도록 CORS가 설정되어 있습니다:

```python
allow_origins=[
    "http://localhost:3000", 
    "http://127.0.0.1:3000",
    "https://medicontents-qa-u45006.vm.elestio.app"
]
```

## 배포

### Elestio 배포

1. **GitHub 저장소 연결**
2. **환경 변수 설정**
3. **Docker 이미지 자동 빌드 및 배포**

### 환경 변수 설정 (Elestio)
- `AIRTABLE_API_KEY`
- `AIRTABLE_BASE_ID`
- `GEMINI_API_KEY`
- `AGENTS_BASE_PATH`

## API 문서

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## 로깅

실시간 로그는 메모리에 저장되며, 각 Post ID별로 관리됩니다.
로그는 다음 정보를 포함합니다:
- 타임스탬프
- 로그 레벨
- 메시지
- 로거 이름

## 에러 처리

모든 API 엔드포인트는 적절한 에러 처리를 포함합니다:
- HTTP 상태 코드 반환
- 상세한 에러 메시지
- 로깅을 통한 디버깅 정보

## 보안

- CORS 설정으로 허용된 도메인만 접근 가능
- 환경 변수를 통한 민감한 정보 관리
- API 키 등의 인증 정보는 서버 환경에서만 관리
