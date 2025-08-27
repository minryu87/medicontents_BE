# Medicontents Backend API

메디컨텐츠 QA 시스템의 백엔드 API 서버입니다.

## 기술 스택

- **Framework**: FastAPI
- **Python**: 3.11
- **Database**: Airtable
- **AI**: Google Gemini API
- **Workflow Automation**: n8n
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
- `POST /api/restart`: 백엔드 서버 재시작

## 워크플로우 상세

### 수동 생성 (Manual Creation)

#### 1. 프론트엔드 → 백엔드
```
POST /api/process-post
{
  "post_id": "QA_xxxxx"
}
```

#### 2. 백엔드 처리 흐름
1. **Post Data Requests 테이블에서 데이터 조회**
2. **상태를 '처리 중'으로 변경**
3. **Agent 실행 (백그라운드에서 비동기 처리)**
   - InputAgent: 입력 데이터 처리
   - PlanAgent: 콘텐츠 계획 수립
   - TitleAgent: 제목 생성
   - ContentAgent: 본문 콘텐츠 생성
4. **결과를 Airtable에 저장**
5. **Medicontent Posts 상태를 '리걸케어 작업 중'으로 변경**
6. **n8n 웹훅 호출**

#### 3. n8n → 백엔드 (수동 생성용)
```
POST https://medicontents-be-u45006.vm.elestio.app/api/process-post
{
  "post_id": "QA_xxxxx"
}
```

#### 4. n8n 워크플로우 처리
1. **Post Data Requests에서 Agent 결과 조회**
2. **HTML 변환 및 최종 콘텐츠 생성**
3. **Medicontent Posts 테이블에 최종 결과 저장**
4. **상태를 '작업 완료'로 변경**
5. **백엔드 완료 API 호출**

#### 5. n8n → 백엔드 완료 통지
```
POST /api/n8n-completion
{
  "post_id": "QA_xxxxx",
  "workflow_id": "medicontent_autoblog_QA_manual",
  "timestamp": "2025-08-27T01:25:39.748-04:00",
  "n8n_result": "success"
}
```

#### 6. 백엔드 후속 처리
1. **완료 상태 확인**
2. **최종 로그 저장**
3. **프론트엔드에 완료 통지**

### 자동 생성 (Auto Generation)

#### 1. 프론트엔드 → n8n
```
POST https://medisales-u45006.vm.elestio.app/webhook/f9cb5f6a-a22b-4141-8e6a-69373d0301d1
{
  "treatmentType": "신경치료",
  "count": 5,
  "timestamp": "2025-08-27T01:25:39.748-04:00",
  "source": "medicontents_QA_auto"
}
```

#### 2. n8n 워크플로우 처리
1. **지정된 개수만큼 Post ID 생성**
2. **Airtable에 초기 데이터 저장**
3. **각 Post ID에 대해 Agent 실행 웹훅 호출**

#### 3. n8n → 백엔드 (자동 생성용)
```
POST https://medicontents-be-u45006.vm.elestio.app/api/process-post
{
  "post_id": "QA_xxxxx"
}
```

#### 4. 백엔드 Agent 실행
- 수동 생성과 동일한 Agent 실행 과정
- 다만 워크플로우 ID가 `medicontent_autoblog_QA_auto`로 구분

#### 5. n8n 완료 처리
- 각 Post ID별로 개별 완료 처리
- 모든 Post ID 완료 시 전체 완료 통지

## n8n 웹훅 구분

### 1. 수동 생성 웹훅
- **URL**: `https://medisales-u45006.vm.elestio.app/webhook/6f545985-77e3-4ee9-8dbf-85ec1d408183`
- **워크플로우 ID**: `medicontent_autoblog_QA_manual`
- **용도**: 사용자가 수동으로 입력한 데이터로 포스팅 생성
- **처리**: 단일 포스팅 생성 및 완료

### 2. 자동 생성 웹훅
- **URL**: `https://medisales-u45006.vm.elestio.app/webhook/f9cb5f6a-a22b-4141-8e6a-69373d0301d1`
- **워크플로우 ID**: `medicontent_autoblog_QA_auto`
- **용도**: 진료 유형과 개수를 지정하여 다수 포스팅 자동 생성
- **처리**: 다수 포스팅 생성 및 개별 완료 처리

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
1. **InputAgent**: 입력 데이터 처리 및 검증
2. **PlanAgent**: 콘텐츠 계획 수립 (Gemini AI 활용)
3. **TitleAgent**: 제목 생성
4. **ContentAgent**: 본문 콘텐츠 생성 및 HTML 변환
5. **EvaluationAgent**: 콘텐츠 품질 평가

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
│   ├── persona_table.csv
│   └── (기타 유틸리티 파일들)
└── __pycache__/
```

## 실시간 로깅 시스템

### 로그 캡처
- **LogCapture 클래스**: 모든 Agent 실행 로그를 실시간으로 캡처
- **CustomLogHandler**: 커스텀 로그 핸들러로 로그 포맷팅
- **realtime_logs**: 메모리 기반 실시간 로그 저장소

### 로그 필터링
프론트엔드에서는 다음 키워드 기반으로 로그를 필터링:
- Step 1~8 로그
- 상태 업데이트 로그
- 성공/완료 로그 (✅, 🌐 등)
- n8n 관련 로그
- 기타 중요 로그

### 로그 형식
```json
{
  "timestamp": "2025-08-27T01:25:39.748-04:00",
  "level": "INFO",
  "message": "INFO:main:후속 작업 완료: QA_xxxxx",
  "logger": "main"
}
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

## 에러 처리

모든 API 엔드포인트는 적절한 에러 처리를 포함합니다:
- HTTP 상태 코드 반환
- 상세한 에러 메시지
- 로깅을 통한 디버깅 정보
- 타임아웃 처리 (25초)

## 보안

- CORS 설정으로 허용된 도메인만 접근 가능
- 환경 변수를 통한 민감한 정보 관리
- API 키 등의 인증 정보는 서버 환경에서만 관리
- 백그라운드 태스크 실행으로 안정성 확보

## 최근 업데이트

### v1.1.0 (2025-08-27)
- **백그라운드 Agent 실행**: 타임아웃 문제 해결을 위해 비동기 백그라운드 처리 구현
- **실시간 로깅 개선**: LogCapture 시스템으로 모든 Agent 로그 실시간 캡처
- **n8n 연동 강화**: 수동/자동 생성 워크플로우 구분 및 완료 처리 개선
- **CORS 설정 개선**: 더 구체적인 헤더 설정으로 프론트엔드 연동 안정성 향상
- **서버 재시작 API**: `/api/restart` 엔드포인트 추가로 운영 편의성 증대
