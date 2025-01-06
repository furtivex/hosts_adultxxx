::BuildHosts
:: Created by Furtivex
@echo OFF && color 17
REM ~~~~~~~~~~~~~~~~~~~~~~~~>
cd /d %~dp0
for %%g in (
grep.exe
libiconv2.dll
libintl3.dll
nircmd.exe
pcre3.dll
regex2.dll
sed.exe
sort_.exe
) DO (
COPY /Y "%CD%\dependencies\%%g" "%WINDIR%" >NUL 2>&1
)
SET "hostsD=C:\Windows\System32\drivers\etc"
IF NOT EXIST "%userprofile%\Documents\GitHub\hosts_adultxxx" MD "%userprofile%\Documents\GitHub\hosts_adultxxx"
SET "githubD=%userprofile%\Documents\GitHub\hosts_adultxxx"
title BuildHosts by Furtivex - Version 1.0.3
ECHO(BuildHosts by Furtivex - Version 1.0.3
ECHO.
ECHO.
REM ~~~~~~~~~~~~~~~~~~~~~~~~>
sc stop Dnscache>NUL
sc config Dnscache start= disabled>NUL
TIMEOUT /T 2 /NOBREAK >NUL
GREP -Ev "^#" <"%githubD%\hosts" >"%TEMP%\repairhosts1"
SED -r "s/(0\.0\.0\.0 )?https?:\/\///; s/(\/|:443)$//" <"%TEMP%\repairhosts1" >"%TEMP%\repairhosts2"
SED -r "/^0\.0\.0\.0/!s/(.*)/0\.0\.0\.0 \1/" <"%TEMP%\repairhosts2" >"%TEMP%\repairhosts3"
SORT_ -f -u <"%TEMP%\repairhosts3" >"%TEMP%\repairhosts4"
SED -r "s/\x22//g" <"%TEMP%\repairhosts4" >"%TEMP%\repairhosts5"
ECHO(# Title: furtivex/hosts_adultxxx>"%TEMP%\repairhosts1"
ECHO(# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>>"%TEMP%\repairhosts1"
ECHO(# Hosts file for browsing porn>>"%TEMP%\repairhosts1"
ECHO(# Filters out ads, banners, redirects and more>>"%TEMP%\repairhosts1"
ECHO(# Raw: https://raw.githubusercontent.com/furtivex/hosts_adultxxx/master/hosts>>"%TEMP%\repairhosts1"
ECHO(# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>>"%TEMP%\repairhosts1"
ECHO(# 127.0.0.1 localhost>>"%TEMP%\repairhosts1"
ECHO(# ::1 localhost>>"%TEMP%\repairhosts1"
ECHO(# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>>"%TEMP%\repairhosts1"
TYPE "%TEMP%\repairhosts5">>"%TEMP%\repairhosts1"
COPY /Y "%TEMP%\repairhosts1" "%githubD%\hosts" >NUL 2>&1
COPY /Y "%TEMP%\repairhosts1" "%hostsD%\hosts" >NUL 2>&1
DEL /F/Q "%TEMP%\repairhosts?" >NUL 2>&1
sc config Dnscache start= auto>NUL
SC start Dnscache>NUL
TIMEOUT /T 2 /NOBREAK >NUL
ipconfig /flushdns >NUL 2>&1
taskkill /f /im git.exe >NUL 2>&1