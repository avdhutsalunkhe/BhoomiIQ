@echo off
echo ===================================================
echo   Starting BhoomiIQ Crop Intelligence System
echo ===================================================
echo Starting Python Backend on port 8000...
start "BhoomiIQ Backend" cmd /k "cd /d %~dp0backend && python run_server.py"

timeout /t 2 /nobreak >nul

echo Starting Flutter Web Frontend on port 5173...
start "BhoomiIQ Frontend" cmd /k "cd /d %~dp0frontend && python -m http.server 5173 --directory build\web"

timeout /t 2 /nobreak >nul
start http://127.0.0.1:5173
echo Both backend and frontend started!
echo Frontend: http://127.0.0.1:5173
echo Backend API Docs: http://127.0.0.1:8000/docs
