$ErrorActionPreference = "Stop"

$hot100Dir = Get-ChildItem -Path "D:\Notes" -Recurse -Directory -Filter "Hot100" |
    Select-Object -First 1 -ExpandProperty FullName
if (-not $hot100Dir) {
    throw "Could not find a Hot100 directory under D:\Notes"
}

$categoryById = @{
    "1"   = "hash"
    "2"   = "linked-list"
    "19"  = "linked-list"
    "21"  = "linked-list"
    "23"  = "linked-list"
    "24"  = "linked-list"
    "25"  = "linked-list"
    "94"  = "binary-tree"
    "101" = "binary-tree"
    "102" = "binary-tree"
    "104" = "binary-tree"
    "108" = "binary-tree"
    "138" = "linked-list"
    "141" = "linked-list"
    "142" = "linked-list"
    "146" = "linked-list"
    "148" = "linked-list"
    "160" = "linked-list"
    "206" = "linked-list"
    "226" = "binary-tree"
    "234" = "linked-list"
    "543" = "binary-tree"
}

$groups = [ordered]@{
    "hash"        = @()
    "linked-list" = @()
    "binary-tree" = @()
}

$mdFiles = Get-ChildItem -Path $hot100Dir -Filter "*.md" -File
foreach ($file in $mdFiles) {
    if ($file.BaseName -match "^(\d+)") {
        $problemId = $Matches[1]
        if ($categoryById.ContainsKey($problemId)) {
            $category = $categoryById[$problemId]
            $tagLine = "#leetcode100/$category"
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
            if ($content -notmatch "(?m)^#leetcode100/") {
                $newContent = $tagLine + "`r`n" + $content
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
            }
            $groups[$category] += $file.BaseName
        }
    }
}

function Sort-ByProblemId {
    param([string[]]$Items)
    return $Items | Sort-Object { [int](($_ -split "\.")[0]) }
}

$indexLines = @()
$indexLines += "# Hot100 Index"
$indexLines += ""

$indexLines += "## #leetcode100/hash"
foreach ($item in (Sort-ByProblemId -Items $groups["hash"])) {
    $indexLines += "- [[$item]]"
}
$indexLines += ""

$indexLines += "## #leetcode100/linked-list"
foreach ($item in (Sort-ByProblemId -Items $groups["linked-list"])) {
    $indexLines += "- [[$item]]"
}
$indexLines += ""

$indexLines += "## #leetcode100/binary-tree"
foreach ($item in (Sort-ByProblemId -Items $groups["binary-tree"])) {
    $indexLines += "- [[$item]]"
}

$indexPath = Join-Path $hot100Dir "0. Hot100-Index.md"
Set-Content -Path $indexPath -Value ($indexLines -join "`r`n") -Encoding Default

Write-Output "Updated tags and wrote index: $indexPath"
