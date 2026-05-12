@echo off
setlocal enabledelayedexpansion
title Printer Fixer and Shared Connection Optimizer

:: Warna (Hijau untuk teks)
color 0A

:: 1. Cek Hak Akses Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Harap klik kanan file ini kemudian pilih 'Run as Administrator'.
    pause
    exit
)

echo.
echo  ======================================================
echo      FIX ERROR 0x800704f8 ^& PRINTER SHARING OPTIMIZER
echo  ======================================================
echo.

:: 2. Mengatur Profile Jaringan ke Private
set "task=Mengatur Network Profile ke Private"
call :ProcessTask
powershell.exe -ExecutionPolicy Bypass -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private" >nul 2>&1
echo [BERHASIL]
echo.

:: 3. Aktifkan Hidden Items di Explorer (Untuk Proses Kerja)
set "task=Mengaktifkan Hidden Items sementara"
call :ProcessTask
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul
echo [BERHASIL]
echo.

:: 4. Copy Registry.pol (Machine)
set "BASE_DIR=%~dp0"
set "task=Sinkronisasi Group Policy (GPEDIT)"
call :ProcessTask
if exist "!BASE_DIR!gpedit\Machine\Registry.pol" (
    if not exist "C:\Windows\System32\GroupPolicy\Machine" mkdir "C:\Windows\System32\GroupPolicy\Machine"
    copy /y "!BASE_DIR!gpedit\Machine\Registry.pol" "C:\Windows\System32\GroupPolicy\Machine\Registry.pol" >nul
)
echo [BERHASIL]
echo.

:: 5. Jalankan Registry Fix (Insecure Guest Auth)
set "task=Menerapkan Insecure Guest Auth Fix"
call :ProcessTask
if exist "!BASE_DIR!registry\AllowInsecureGuestAuth.reg" (
    regedit.exe /s "!BASE_DIR!registry\AllowInsecureGuestAuth.reg"
)
reg add "HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation" /v "AllowInsecureGuestAuth" /t REG_DWORD /d 1 /f >nul
echo [BERHASIL]
echo.

:: 6. Import Security Policy
set "POLICY_FILE=shared_printer_secpol_configurations_for_win_11.inf"
set "FULL_POLICY_PATH=!BASE_DIR!secpol\%POLICY_FILE%"
if exist "%FULL_POLICY_PATH%" (
    set "task=Mengimpor Security Policy"
    call :ProcessTask
    if exist "%temp%\printer_fix.sdb" del /f /q "%temp%\printer_fix.sdb"
    secedit /configure /db "%temp%\printer_fix.sdb" /cfg "%FULL_POLICY_PATH%" /areas SECURITYPOLICY /log "%temp%\secedit_log.txt" /quiet
    echo [BERHASIL]
    echo.
)

:: 7. Refresh Policy & Restart Services
set "task=Memperbarui Sistem Policy"
call :ProcessTask
gpupdate /force >nul
echo [BERHASIL]
echo.

set "task=Me-restart Spooler dan Network Service"
call :ProcessTask
net stop spooler /y >nul 2>&1
net start spooler >nul 2>&1
net stop lanmanworkstation /y >nul 2>&1
net start lanmanworkstation >nul 2>&1
echo [BERHASIL]
echo.

:: 8. Kembalikan Hidden Items (Menonaktifkan)
set "task=Merapikan Explorer (Sembunyikan Hidden Items)"
call :ProcessTask
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 2 /f >nul
echo [BERHASIL]
echo.

echo  ======================================================
echo      PROSES SELESAI! Sistem perlu restart.
echo  ======================================================
echo.
echo  Tekan tombol apa saja untuk MERESTART komputer sekarang...
pause >nul

echo.
echo  Komputer akan restart dalam 15 detik. 
echo  Simpan semua pekerjaan Anda!
shutdown /r /t 15 /c "Restart otomatis setelah perbaikan Shared Printer."
exit

:: --- SUBROUTINE LOADING ---
:ProcessTask
set "displayTask=[*] %task%"
set /p "=%displayTask% " <nul
for /L %%i in (1,1,3) do (
    set /p "=. " <nul
    timeout /t 1 >nul
)
echo.
goto :eof
