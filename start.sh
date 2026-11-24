#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "============================================"
echo "  仁和医院预约挂号系统"
echo "============================================"

if ! command -v java >/dev/null 2>&1; then
  echo "[错误] 未检测到 Java，请先安装 JDK 17 或更高版本。"
  exit 1
fi

java -version

if [ -z "${DB_PASSWORD:-}" ]; then
  read -r -p "请输入 MySQL 密码（直接回车使用 123456）：" DB_PASSWORD
fi
export DB_PASSWORD="${DB_PASSWORD:-123456}"

if command -v open >/dev/null 2>&1; then
  (sleep 15 && open http://localhost:8080) &
elif command -v xdg-open >/dev/null 2>&1; then
  (sleep 15 && xdg-open http://localhost:8080) &
fi

./mvnw -s settings.xml -q -DskipTests spring-boot:run
