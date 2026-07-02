@echo off
setlocal
cd /d "%~dp0"

if not exist "ChatLogAnalyzer.exe" (
  echo ERROR: ChatLogAnalyzer.exe is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal" (
  echo ERROR: _internal folder is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\base_library.zip" (
  echo ERROR: Python standard library bundle is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\python3.dll" (
  echo ERROR: Python runtime file is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\python312.dll" (
  echo ERROR: Python runtime file is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\VCRUNTIME140.dll" (
  echo ERROR: Microsoft runtime file is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\VCRUNTIME140_1.dll" (
  echo ERROR: Microsoft runtime file is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\PySide6\Qt6Core.dll" (
  echo ERROR: PySide6 core file is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\PySide6\Qt6Widgets.dll" (
  echo ERROR: PySide6 widgets file is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\PySide6\plugins\platforms\qwindows.dll" (
  echo ERROR: Windows display plugin is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

if not exist "_internal\logo\kddi_2026_logo_transparent.png" (
  echo ERROR: Corporate logo image is missing.
  echo Please copy the full app folder again.
  pause
  exit /b 1
)

start "" "%~dp0ChatLogAnalyzer.exe"
exit /b 0
