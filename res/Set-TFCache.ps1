#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [string]$CacheRoot,
    [string]$CacheItem,
    [string]$CacheValue,
    [string]$CacheToken,
    [hashtable]$CacheOther
)

$cachePath = [System.IO.Path]::Combine($PWD, $CacheRoot)
if (-not (Test-Path -PathType Container $cachePath)) {
    mkdir -Force $cachePath | Out-Null
}
$cacheFile = [System.IO.Path]::Combine($cachePath, "$($CacheItem).cache.json")

$timeNow = [datetime]::UtcNow.ToString("yyyyMMddHHmmss")

[System.IO.File]::WriteAllText($cacheFile, (@{
    stamp = $timeNow
    value = $CacheValue
    token = $CacheToken
    other = $CacheOther
} | ConvertTo-Json))

Write-Output "***** CACHE: ******************"
Write-Output "Updated CACHE [$($CacheRoot)] for ENTRY [$($CacheItem)] at [$($timeNow)]"
