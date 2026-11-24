@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 仁和医院预约挂号系统

echo ============================================
echo   仁和医院预约挂号系统
echo ============================================
echo.

where java >nul 2>nul
if errorlevel 1 (
    echo [错误] 未检测到 Java，请先安装 JDK 17 或更高版本。
    echo 下载地址：https://adoptium.net/
    pause
    exit /b 1
)

if defined JAVA_HOME if exist "%JAVA_HOME%\bin\javac.exe" goto jdk_ready

set "JAVA_HOME="
for /f "tokens=2 delims==" %%v in ('java -XshowSettings:properties -version 2^>^&1 ^| findstr /i "java.home"') do set "JAVA_HOME=%%v"
if defined JAVA_HOME if "%JAVA_HOME:~0,1%"==" " set "JAVA_HOME=%JAVA_HOME:~1%"
if defined JAVA_HOME if not exist "%JAVA_HOME%\bin\javac.exe" set "JAVA_HOME="

if not defined JAVA_HOME for /d %%d in ("C:\Program Files\Java\jdk*") do if exist "%%d\bin\javac.exe" set "JAVA_HOME=%%d"
if not defined JAVA_HOME for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk*") do if exist "%%d\bin\javac.exe" set "JAVA_HOME=%%d"
if not defined JAVA_HOME for /d %%d in ("C:\Program Files\Microsoft\jdk*") do if exist "%%d\bin\javac.exe" set "JAVA_HOME=%%d"
if not defined JAVA_HOME for /d %%d in ("%USERPROFILE%\.jdks\*") do if exist "%%d\bin\javac.exe" set "JAVA_HOME=%%d"

if not defined JAVA_HOME goto jdk_not_found
goto jdk_ready

:jdk_not_found
echo.
echo [ERROR] JDK not found
echo Install JDK 17 or newer
echo Or set JAVA_HOME to your JDK folder
echo Example: C:\Program Files\Java\jdk-21
pause
exit /b 1

:jdk_ready
set "PATH=%JAVA_HOME%\bin;%PATH%"

for /f "tokens=2" %%v in ('javac -version 2^>^&1') do set "JAVAC_VER=%%v"
for /f "tokens=1 delims=." %%m in ("%JAVAC_VER%") do set "JAVA_MAJOR=%%m"
if %JAVA_MAJOR% LSS 17 (
    echo [错误] 当前 JDK 版本 %JAVAC_VER%，本项目需要 JDK 17 或更高版本。
    pause
    exit /b 1
)

echo 当前 Java 版本：
java -version
echo JDK 路径：%JAVA_HOME%
echo.

powershell -NoProfile -Command "if (-not (Test-NetConnection -ComputerName 127.0.0.1 -Port 3306 -InformationLevel Quiet)) { exit 1 }" >nul 2>nul
if errorlevel 1 (
    echo [警告] 未检测到 3306 端口的 MySQL 服务。
    echo 请确认 MySQL 已启动；如端口不同，请修改 application.yml 或设置 DB_URL。
    echo.
)

if "%DB_PASSWORD%"=="" (
    set /p DB_PASSWORD=请输入 MySQL 密码（直接回车使用 123456）：
)
if "%DB_PASSWORD%"=="" set DB_PASSWORD=123456

echo.
echo 正在启动服务……
echo Open http://localhost:8080 after startup
echo.
if exist "renhe-hospital.jar" (
    echo 使用内置程序包启动，无需 Maven
    "%JAVA_HOME%\bin\java.exe" -jar "renhe-hospital.jar"
) else (
    echo 未找到内置程序包，改用 Maven 启动，首次需要下载依赖
    call mvnw.cmd -s settings.xml -q -DskipTests spring-boot:run
)

echo.
echo 服务已停止。
pause
