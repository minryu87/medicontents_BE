#!/bin/bash

echo "=== Medicontents Backend Restart Script ==="

# 현재 상태 확인
echo "1. 현재 Docker 컨테이너 상태:"
docker ps | grep medicontents-be

echo ""
echo "2. 현재 uvicorn 프로세스 상태:"
docker exec medicontents-be ps aux | grep uvicorn

echo ""
echo "3. 컨테이너 재시작 중..."
docker restart medicontents-be

echo ""
echo "4. 재시작 후 상태 확인:"
sleep 3
docker ps | grep medicontents-be

echo ""
echo "5. 로그 확인:"
docker logs --tail 10 medicontents-be

echo ""
echo "=== 재시작 완료 ==="
echo "API 테스트: curl https://medicontents-be-u45006.vm.elestio.app/"
