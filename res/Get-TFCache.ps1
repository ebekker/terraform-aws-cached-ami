#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [string]$CacheRoot,
    [int]$ExpireSecs=60*60*12 ## Default is to cache for 12 hours
)

$cacheOut = [ordered]@{}
$cachePath = [System.IO.Path]::Combine($PWD, $CacheRoot)
if (Test-Path -PathType Container $cachePath) {
    $cacheFiles = Get-ChildItem -Path $cachePath -Filter *.cache.json

    ## Compute expiration time as now - expire secs
    $expTime  = [datetime]::UtcNow.AddSeconds(-$ExpireSecs)
    $expStamp = $expTime.ToString("yyyyMMddHHmmss")

    Write-Verbose "expTime = $expTime"
    Write-Verbose "expStamp = $expStamp"

    foreach ($cf in $cacheFiles) {
        $cacheKey = $cf.Name -ireplace ".cache.json$",""
        $cacheText = [System.IO.File]::ReadAllText($cf.FullName)
        $cacheEntry = ConvertFrom-Json $cacheText -AsHashtable

        Write-Verbose "entStamp = $($cacheEntry.stamp)"
        if ($cacheEntry.stamp -gt $expStamp) {
            ## Entry time is greater than expiration
            ## time, so include value in cached results
            $cacheOut["$cacheKey"] = $cacheEntry.value
            $cacheOut["$cacheKey/token"] = $cacheEntry.token

            if ($cacheEntry.other -and $cacheEntry.other.count) {
                foreach ($otherKey in $cacheEntry.other.keys) {
                    $cacheOut["$cacheKey/other/$otherKey"] = $cacheEntry.other[$otherKey]
                }
            }
        }
    }
}

$cacheOut | ConvertTo-Json
