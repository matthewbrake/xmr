@echo off
setlocal EnableDelayedExpansion
title Privacy Nexus Controller v3.5
color 0A
mode con: cols=120 lines=40

:::############################ GLOBAL CONFIGURATION ###########################
:: Core Paths
set "ROOT=%~dp0"
set "LOG_DIR=%ROOT%logs"
set "DATA_DIR=%ROOT%data"
set "CONFIG_DIR=%ROOT%config"
set "BIN_DIR=%ROOT%bin\win"
set "WALLET_DIR=%ROOT%wallets"
set "CERT_DIR=%ROOT%certs"

:: Service Ports
set "TOR_SOCKS_PORT=9051"
set "TOR_CONTROL_PORT=9051"
set "I2P_PROXY_PORT=4445"
set "I2P_HTTP_PORT=4444"
set "MONERO_RPC_PORT=18089"
set "MONERO_P2P_PORT=18080"

:: Network Addresses
set "TOR_PROXY_ADDR=vekhhih3zfq5mfj6jdb3ul25ycpwtqutoxuh4lj4x2lkacl7ko2i3dyd.onion"
set "I2P_PROXY_ADDR=acetone.i2p"

:: Executable Paths
set "TOR_EXE=%BIN_DIR%\tor\tor.exe"
set "I2PD_EXE=%BIN_DIR%\i2pd\i2pd.exe"
set "MONEROD_EXE=%BIN_DIR%\monero\monerod.exe"
set "MONERO_WALLET_GUI=%BIN_DIR%\monero\monero-wallet-gui.exe"
set "CURL_EXE=curl.exe"

:: Configuration Files
set "TOR_CONFIG=%CONFIG_DIR%\tor\torrc"
set "I2PD_CONFIG=%CONFIG_DIR%\i2pd\i2pd.conf"
set "TUNNELS_CONFIG=%CONFIG_DIR%\i2pd\tunnels.conf"
set "MONERO_CONFIG=%CONFIG_DIR%\monero\monero.conf"
set "MONERO_CONFIG_TOR=%CONFIG_DIR%\monero\monero-tor.conf"
set "WALLET_CONFIG=%CONFIG_DIR%\monero\wallet\wallet.conf"
set "WALLET_KEYS=%WALLET_DIR%\keys\wallet.keys"

:: SSL Configuration
set "RPC_SSL_CERT=%CERT_DIR%\node-cert.pem"
set "RPC_SSL_KEY=%CERT_DIR%\node-key.pem"

:: Authentication
set "RPC_USER=admin"
set "RPC_PASS=password"

:: Service Flags
set "TOR_DETACHED=true"
set "I2P_DETACHED=false"
set "MONERO_DETACHED=false"

:: Logging System
set "SCRIPT_LOG=%LOG_DIR%controller.log"
set "TOR_LOG=%LOG_DIR%tor.log"
set "I2P_LOG=%LOG_DIR%i2p.log"
set "MONERO_LOG=%LOG_DIR%monero.log"
set "DEBUG_MODE=true"

:: Service Status Trackers
set "TOR_STATUS=INACTIVE"
set "I2P_STATUS=INACTIVE"
set "MONERO_STATUS=INACTIVE"

:::############################### INITIALIZATION ##############################
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
if not exist "%WALLET_DIR%" mkdir "%WALLET_DIR%"
if not exist "%CERT_DIR%" mkdir "%CERT_DIR%"

echo [%date% %time%] Controller initialized >> "%SCRIPT_LOG%"
call :CHECK_SERVICES

:::################################ MAIN MENU ###################################
:MAIN_MENU
cls
echo.
echo ============== PRIVACY NEXUS CONTROLLER v3.5 ==============
echo 1) Service Control Center      5) Network Diagnostics
echo 2) Monero Node Management      6) System Utilities
echo 3) Wallet Operations           7) Configuration Center
echo 4) Log Management              8) Advanced Tools
echo 9) Help Center                 X) Exit
echo ===========================================================
echo [SERVICE STATUS]
echo Tor:    %TOR_STATUS%  I2P: %I2P_STATUS%  Monero: %MONERO_STATUS%
echo [PORTS] Tor: %TOR_SOCKS_PORT%  I2P: %I2P_PROXY_PORT%  Monero: %MONERO_RPC_PORT%
echo ===========================================================

choice /c 123456789X /n /m "Select operation: "
goto MENU_%errorlevel%

:::############################### MENU HANDLERS ###############################
:MENU_1
call :SERVICE_CONTROL_CENTER
goto MAIN_MENU

:MENU_2
call :MONERO_MGMT_MENU
goto MAIN_MENU

:MENU_3
call :WALLET_OPS
goto MAIN_MENU

:MENU_4
call :LOG_MANAGER
goto MAIN_MENU

:MENU_5
call :NETWORK_DIAGNOSTICS
goto MAIN_MENU

:MENU_6
call :SYSTEM_UTILITIES
goto MAIN_MENU

:MENU_7
call :CONFIG_MENU
goto MAIN_MENU

:MENU_8
call :ADVANCED_TOOLS
goto MAIN_MENU

:MENU_9
call :HELP_CENTER
goto MAIN_MENU

:MENU_10
exit /b

:::########################## SERVICE CONTROL CENTER ###########################
:SERVICE_CONTROL_CENTER
cls
echo.
echo ============ SERVICE CONTROL CENTER =============
echo 1) Start Tor            5) Start I2P
echo 2) Stop Tor             6) Stop I2P
echo 3) Restart Tor          7) Restart I2P
echo 4) Tor Status           8) I2P Status
echo ----------------------------
echo 9) Start Monero         A) Stop Monero
echo B) Restart Monero       C) Monero Status
echo ----------------------------
echo D) Start All Services   E) Stop All Services
echo 0) Return to Main Menu
echo ================================================

choice /c 123456789ABCDE0 /n /m "Select operation: "
set "choice=!errorlevel!"
set "service=" & set "action="

if !choice! equ 1 set "service=Tor" & set "action=start"
if !choice! equ 2 set "service=Tor" & set "action=stop"
if !choice! equ 3 set "service=Tor" & set "action=restart"
if !choice! equ 4 set "service=Tor" & set "action=status"
if !choice! equ 5 set "service=I2P" & set "action=start"
if !choice! equ 6 set "service=I2P" & set "action=stop"
if !choice! equ 7 set "service=I2P" & set "action=restart"
if !choice! equ 8 set "service=I2P" & set "action=status"
if !choice! equ 9 set "service=Monero" & set "action=start"
if !choice! equ 10 set "service=Monero" & set "action=stop"
if !choice! equ 11 set "service=Monero" & set "action=restart"
if !choice! equ 12 set "service=Monero" & set "action=status"
if !choice! equ 13 call :START_ALL_SERVICES
if !choice! equ 14 call :STOP_ALL_SERVICES
if !choice! equ 15 goto MAIN_MENU  ;;; FIXED RETURN TO MAIN

if defined service (
    if "!action!"=="start" call :START_SERVICE "!service!"
    if "!action!"=="stop" call :STOP_SERVICE "!service!"
    if "!action!"=="restart" call :RESTART_SERVICE "!service!"
    if "!action!"=="status" call :SERVICE_STATUS "!service!"
)
goto SERVICE_CONTROL_CENTER

:::############################# MONERO MANAGEMENT #############################
:MONERO_MGMT_MENU
:MONERO_SUBMENU
cls
echo.
echo ============== MONERO NODE MANAGEMENT ==============
echo 1) Start Node           6) Blockchain Height
echo 2) Restart Node         7) Update Node
echo 3) Stop Node            8) Validate Config
echo 4) Node Status          9) Mining Controls
echo 5) Sync Status          0) Return to Main
echo ====================================================

choice /c 1234567890 /n /m "Select action: "
set "CHOICE=!errorlevel!"

if !CHOICE! equ 1 call :START_SERVICE "Monero"
if !CHOICE! equ 2 call :RESTART_SERVICE "Monero"
if !CHOICE! equ 3 call :STOP_SERVICE "Monero"
if !CHOICE! equ 4 call :SERVICE_STATUS "Monero"
if !CHOICE! equ 5 call :MONERO_SYNC_STATUS
if !CHOICE! equ 6 call :MONERO_BLOCK_HEIGHT
if !CHOICE! equ 7 call :MONERO_UPDATE
if !CHOICE! equ 8 call :VALIDATE_CONFIG
if !CHOICE! equ 9 call :MINING_CONTROLS
if !CHOICE! equ 10 goto MAIN_MENU  ;;; FIXED RETURN TO MAIN

goto MONERO_SUBMENU

:::########################### NETWORK DIAGNOSTICS ############################
:NETWORK_DIAGNOSTICS
cls
echo.
echo ============= NETWORK DIAGNOSTICS =============
echo 1) Test Tor Connectivity
echo 2) Test I2P Connectivity
echo 3) Test Monero RPC (Local)
echo 4) Test Monero via Tor
echo 5) Test Monero via I2P
echo 6) Port Status Check
echo 7) Network Latency Test
echo 8) Connection Analysis
echo 0) Return to Main Menu
echo ===============================================

choice /c 123456780 /n /m "Select test: "
set "choice=!errorlevel!"

if !choice! equ 1 (
    echo Testing Tor connectivity... >> "%SCRIPT_LOG%"
    start "Tor Test" cmd /k ""%CURL_EXE%" --socks5-hostname 127.0.0.1:%TOR_SOCKS_PORT% https://check.torproject.org"
)
if !choice! equ 2 (
    echo Testing I2P connectivity... >> "%SCRIPT_LOG%"
    start "I2P Test" cmd /k ""%CURL_EXE%" --proxy socks5h://127.0.0.1:%I2P_PROXY_PORT% http://%I2P_PROXY_ADDR%"
)
if !choice! equ 3 (
    echo Testing Monero RPC locally... >> "%SCRIPT_LOG%"
    start "Monero RPC Test" cmd /k ""%CURL_EXE%" -X POST http://127.0.0.1:%MONERO_RPC_PORT%/json_rpc -d ""{\""jsonrpc\"":\""2.0\"",\""id\"":\""0\"",\""method\"":\""get_info\""}"" -H ""Content-Type: application/json"""
)
if !choice! equ 4 (
    echo Testing Monero via Tor... >> "%SCRIPT_LOG%"
    start "Monero Tor Test" cmd /k ""%CURL_EXE%" --socks5-hostname 127.0.0.1:%TOR_SOCKS_PORT% -u %RPC_USER%:%RPC_PASS% --digest -X POST http://%TOR_PROXY_ADDR%:%MONERO_RPC_PORT%/json_rpc -d ""{\""jsonrpc\"":\""2.0\"",\""id\"":\""0\"",\""method\"":\""get_info\""}"" -H ""Content-Type: application/json"""
)
if !choice! equ 5 (
    echo Testing Monero via I2P... >> "%SCRIPT_LOG%"
    start "Monero I2P Test" cmd /k ""%CURL_EXE%" --proxy socks5h://127.0.0.1:%I2P_PROXY_PORT% -u %RPC_USER%:%RPC_PASS% --digest -X POST http://%I2P_PROXY_ADDR%:%MONERO_RPC_PORT%/json_rpc -d ""{\""jsonrpc\"":\""2.0\"",\""id\"":\""0\"",\""method\"":\""get_info\""}"" -H ""Content-Type: application/json"""
)
if !choice! equ 6 (
    call :PORT_STATUS
    pause
)
if !choice! equ 7 (
    ping -n 4 1.1.1.1 && ping -n 4 8.8.8.8
    pause
)
if !choice! equ 8 (
    start "Network Analysis" cmd /k "netstat -ano | findstr ESTABLISHED"
)
goto MAIN_MENU

:::############################# ADVANCED TOOLS ###############################
:ADVANCED_TOOLS
cls
echo.
echo ============== ADVANCED TOOLS ==============
echo 1) Manual Tor Command
echo 2) Manual I2P Command
echo 3) Execute Monero RPC
echo 4) Netstat Analysis
echo 5) Service Debug Info
echo 0) Return to Main
echo ============================================

choice /c 123450 /n /m "Select tool: "
set "choice=!errorlevel!"

if !choice! equ 1 call :MANUAL_CMD "Tor"
if !choice! equ 2 call :MANUAL_CMD "I2P"
if !choice! equ 3 call :RPC_INTERFACE
if !choice! equ 4 call :NETSTAT_ANALYSIS
if !choice! equ 5 call :SERVICE_DEBUG
goto MAIN_MENU

:MANUAL_CMD
setlocal
set "SERVICE=%~1"
set /p "CMD=Enter %SERVICE% command: "
echo [%date% %time%] Manual %SERVICE% command: !CMD! >> "%SCRIPT_LOG%"
start "Manual Command" cmd /k "!CMD!"
endlocal
exit /b

:RPC_INTERFACE
cls
echo.
echo ============= MONERO RPC INTERFACE =============
echo 1) Node Info             6) Transaction Pool
echo 2) Block Count           7) Peer List
echo 3) Last Block Header     8) Connections
echo 4) Version Info          9) Fee Estimate
echo 5) Network Stats         0) Return
echo ===============================================

choice /c 1234567890 /n /m "Select RPC command: "
set "RPC_METHOD="
set "RPC_PARAMS="

goto RPC_CMD_%errorlevel%

:RPC_CMD_1
set "RPC_METHOD=get_info"
goto SEND_RPC

:RPC_CMD_2
set "RPC_METHOD=get_block_count"
goto SEND_RPC

:RPC_CMD_3
set "RPC_METHOD=get_last_block_header"
goto SEND_RPC

:RPC_CMD_4
set "RPC_METHOD=get_version"
goto SEND_RPC

:RPC_CMD_5
set "RPC_METHOD=print_net_stats"
goto SEND_RPC

:RPC_CMD_6
set "RPC_METHOD=get_transaction_pool"
goto SEND_RPC

:RPC_CMD_7
set "RPC_METHOD=get_peer_list"
goto SEND_RPC

:RPC_CMD_8
set "RPC_METHOD=get_connections"
goto SEND_RPC

:RPC_CMD_9
set "RPC_METHOD=get_fee_estimate"
set "RPC_PARAMS={\"grace_blocks\":10}"
goto SEND_RPC

:RPC_CMD_10
goto ADVANCED_TOOLS

:SEND_RPC
echo [%date% %time%] RPC: %RPC_METHOD% >> "%SCRIPT_LOG%"
set "JSON={\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"%RPC_METHOD%\"}"
if defined RPC_PARAMS set "JSON={\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"%RPC_METHOD%\",\"params\":%RPC_PARAMS%}"

start "RPC Result" cmd /k ""%CURL_EXE%" -u %RPC_USER%:%RPC_PASS% -X POST http://127.0.0.1:%MONERO_RPC_PORT%/json_rpc -d "%JSON%" -H "Content-Type: application/json""
goto RPC_INTERFACE

:::########################### SERVICE FUNCTIONS ###############################
:START_SERVICE
setlocal
set "service=%~1"
echo [%date% %time%] Starting !service! service >> "%SCRIPT_LOG%"

if "!service!"=="Tor" (
    if not exist "%TOR_EXE%" (echo ERROR: Tor executable missing! & pause & exit /b)
    if "%TOR_DETACHED%"=="true" (
        start "Tor Service" /B "%TOR_EXE%" -f "%TOR_CONFIG%" > "%TOR_LOG%" 2>&1
    ) else (
        start "Tor Service" cmd /k ""%TOR_EXE%" -f "%TOR_CONFIG%""
    )
    set "TOR_STATUS=ACTIVE"
)
if "!service!"=="I2P" (
    if not exist "%I2PD_EXE%" (echo ERROR: I2P executable missing! & pause & exit /b)
    if "%I2P_DETACHED%"=="true" (
        start "I2P Service" /B "%I2PD_EXE%" --datadir="%DATA_DIR%\i2p" --conf="%I2PD_CONFIG%" --tunconf="%TUNNELS_CONFIG%" > "%I2P_LOG%" 2>&1
    ) else (
        start "I2P Service" cmd /k ""%I2PD_EXE%" --datadir="%DATA_DIR%\i2p" --conf="%I2PD_CONFIG%" --tunconf="%TUNNELS_CONFIG%""
    )
    set "I2P_STATUS=ACTIVE"
)
if "!service!"=="Monero" (
    if not exist "%MONEROD_EXE%" (echo ERROR: Monero executable missing! & pause & exit /b)
    if "%MONERO_DETACHED%"=="true" (
        start "Monero Node" /B "%MONEROD_EXE%" --config-file "%MONERO_CONFIG%" --rpc-login %RPC_USER%:%RPC_PASS% > "%MONERO_LOG%" 2>&1
    ) else (
        start "Monero Node" cmd /k ""%MONEROD_EXE%" --config-file "%MONERO_CONFIG%" --rpc-login %RPC_USER%:%RPC_PASS%""
    )
    set "MONERO_STATUS=ACTIVE"
)
endlocal & exit /b

:STOP_SERVICE
setlocal
set "service=%~1"
echo [%date% %time%] Stopping !service! service >> "%SCRIPT_LOG%"

if "!service!"=="Tor" (
    taskkill /F /IM tor.exe >nul 2>&1
    set "TOR_STATUS=INACTIVE"
)
if "!service!"=="I2P" (
    taskkill /F /IM i2pd.exe >nul 2>&1
    set "I2P_STATUS=INACTIVE"
)
if "!service!"=="Monero" (
    taskkill /F /IM monerod.exe >nul 2>&1
    set "MONERO_STATUS=INACTIVE"
)
endlocal & exit /b

:SERVICE_STATUS
setlocal
set "service=%~1"
if "!service!"=="Tor" (
    tasklist | findstr /i "tor.exe" >nul && (
        echo Tor: RUNNING [PID: !errorlevel!]
        netstat -ano | findstr ":%TOR_SOCKS_PORT%"
    ) || echo Tor: STOPPED
)
if "!service!"=="I2P" (
    tasklist | findstr /i "i2pd.exe" >nul && (
        echo I2P: RUNNING [PID: !errorlevel!]
        netstat -ano | findstr ":%I2P_PROXY_PORT%"
    ) || echo I2P: STOPPED
)
if "!service!"=="Monero" (
    tasklist | findstr /i "monerod.exe" >nul && (
        echo Monero: RUNNING [PID: !errorlevel!]
        netstat -ano | findstr ":%MONERO_RPC_PORT%"
    ) || echo Monero: STOPPED
)
pause
endlocal & exit /b

:::########################### OTHER FUNCTIONS #################################
:PORT_STATUS
echo [Port Check] >> "%SCRIPT_LOG%"
echo Tor (%TOR_SOCKS_PORT%): & netstat -ano | findstr ":%TOR_SOCKS_PORT% "
echo I2P (%I2P_PROXY_PORT%): & netstat -ano | findstr ":%I2P_PROXY_PORT% "
echo Monero (%MONERO_RPC_PORT%): & netstat -ano | findstr ":%MONERO_RPC_PORT% "
exit /b

:NETSTAT_ANALYSIS
start "Network Analysis" cmd /k "netstat -ano"
exit /b

:SERVICE_DEBUG
echo [Service Debug] >> "%SCRIPT_LOG%"
echo === Tor Configuration ===
type "%TOR_CONFIG%"
echo.
echo === I2P Configuration ===
type "%I2PD_CONFIG%"
echo.
echo === Monero Configuration ===
type "%MONERO_CONFIG%"
pause
exit /b

:CHECK_SERVICES
tasklist /FI "IMAGENAME eq tor.exe" >nul && set "TOR_STATUS=ACTIVE" || set "TOR_STATUS=INACTIVE"
tasklist /FI "IMAGENAME eq i2pd.exe" >nul && set "I2P_STATUS=ACTIVE" || set "I2P_STATUS=INACTIVE"
tasklist /FI "IMAGENAME eq monerod.exe" >nul && set "MONERO_STATUS=ACTIVE" || set "MONERO_STATUS=INACTIVE"
exit /b

:START_ALL_SERVICES
call :START_SERVICE "Tor"
call :START_SERVICE "I2P"
call :START_SERVICE "Monero"
exit /b

:STOP_ALL_SERVICES
call :STOP_SERVICE "Tor"
call :STOP_SERVICE "I2P"
call :STOP_SERVICE "Monero"
exit /b

:::############################# EXIT HANDLING ################################
exit /b
