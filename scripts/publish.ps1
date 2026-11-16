<#
  Phát hành MỘT gói phần mềm tích hợp của VAS vào repo GitHub của Vietnews (PO 16/11: kho phần mềm của Vietnews là nguồn tải ƯU TIÊN khi cài VAS;
  phần mềm chủ đạo có repo riêng để phát triển trước cộng đồng khi cần). Chạy trong GitHub Actions (windows-latest, pwsh, gh, GITHUB_TOKEN của chính repo).

  Một bản phát hành = thẻ <id>-<phiên bản> (ký tự lạ → '-'; CÙNG quy tắc với Mirror-Url trong setup/tools-install.ps1), gồm:
   - tệp chạy ĐÚNG tệp VAS ghim: tải từ nguồn gốc, mã băm SHA-256 phải khớp manifest.json — sai một byte là DỪNG, không phát hành;
   - mã nguồn tương ứng (GPL/LGPL…): mục "sources" của gói + danh mục thành phần nguon/<id>.json (từng thành phần + công thức dựng), tên "nguon--…";
   - văn bản giấy phép (licenseFiles), SHA256SUMS.txt của mọi tệp, ghi chú phát hành (giấy phép, nguồn gốc, tệp nguồn tải không được).
  Đã có bản phát hành chứa tệp chạy → bỏ qua (chạy lại an toàn); thiếu tệp nguồn của lần trước → tải bổ sung.
#>
param([Parameter(Mandatory)][string]$Id)
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$root = Split-Path $PSScriptRoot
$m = Get-Content (Join-Path $root "manifest.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$p = $m.packages | Where-Object id -eq $Id | Select-Object -First 1
if (-not $p) { throw "Khong co goi $Id trong manifest.json" }
if (-not $p.file -or -not $p.sha256) { throw "Goi $Id thieu tep / ma bam ghim" }
$tag = ("$($p.id)-$($p.version)" -replace '[^A-Za-z0-9._-]', '-')
$work = Join-Path $env:RUNNER_TEMP "vas-$tag"
New-Item -ItemType Directory -Force $work | Out-Null

function Fetch($url, $dest) {
    & curl.exe -L --fail --silent --show-error --retry 4 --retry-delay 5 --connect-timeout 30 -o $dest $url
    return $LASTEXITCODE -eq 0 -and (Test-Path $dest)
}
function Sha($f) { (Get-FileHash $f -Algorithm SHA256).Hash.ToLowerInvariant() }
# tên tài sản GitHub: chỉ ký tự an toàn (GitHub tự đổi ký tự lạ → không đoán được tên); trùng tên thì thêm số
$used = @{}
function AssetName($name) {
    $n = ($name -replace '[^A-Za-z0-9._+-]', '_')
    $b = $n; $k = 2
    while ($used.ContainsKey($n.ToLowerInvariant())) { $n = "$([IO.Path]::GetFileNameWithoutExtension($b))-$k$([IO.Path]::GetExtension($b))"; $k++ }
    $used[$n.ToLowerInvariant()] = $true
    return $n
}

# ---- đã phát hành?
$existing = @()
$has = $false
$view = & gh release view $tag --json assets 2>$null
if ($LASTEXITCODE -eq 0) { $existing = @(($view | ConvertFrom-Json).assets.name); $has = $true }
foreach ($a in $existing) { $used[$a.ToLowerInvariant()] = $true }
$binName = $p.file
if ($binName -ne ($binName -replace '[^A-Za-z0-9._+-]', '_')) { throw "Ten tep $binName co ky tu GitHub se doi - VAS khong tim duoc; doi ten trong manifest" }

# ---- 1. tệp chạy: đúng mã băm ghim
$sums = [System.Collections.Generic.List[string]]::new()
$bin = Join-Path $work $binName
if (-not ($existing -contains $binName)) {
    Write-Host "Tai tep chay: $($p.url)"
    if (-not (Fetch $p.url $bin)) { throw "Tai that bai: $($p.url)" }
    $h = Sha $bin
    if ($h -ne $p.sha256.ToLowerInvariant()) { throw "MA BAM KHONG KHOP cho $binName : $h (ghim $($p.sha256)) - KHONG phat hanh" }
    Write-Host "Ma bam khop: $h"
} else { Write-Host "Da co $binName trong ban phat hanh $tag" }
$sums.Add("$($p.sha256.ToLowerInvariant())  $binName")

# ---- 2. danh sách mã nguồn + giấy phép
$srcs = [System.Collections.Generic.List[object]]::new()
foreach ($u in @($p.sources)) { if ($u) { $srcs.Add([pscustomobject]@{ url = $u; what = "nguon (manifest)" }) } }
$invFile = Join-Path $root "nguon\$($p.id).json"
$gaps = @()
if (Test-Path $invFile) {
    $inv = Get-Content $invFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($inv.version -ne $p.version) { throw "nguon\$($p.id).json la cua phien ban $($inv.version), manifest ghim $($p.version)" }
    foreach ($c in @($inv.components) + @($inv.buildRecipe)) { if ($c.url) { $srcs.Add([pscustomobject]@{ url = $c.url; what = "$($c.name) $($c.version)".Trim() }) } }
    $gaps = @($inv.residualGaps | Where-Object { $_ })
}
$seen = @{}
$srcs = @($srcs | Where-Object { $_.url -match '^https?://' -and -not $seen.ContainsKey($_.url) -and ($seen[$_.url] = $true) })
$lic = @($p.licenseFiles | Where-Object { $_ })

# ---- 3. tạo / bổ sung bản phát hành
$notes = Join-Path $work "NOTES.md"
$failed = [System.Collections.Generic.List[string]]::new()
$body = @(
    "# $($p.title) $($p.version)",
    "",
    "Bản phân phối của **Vietnews AI Studio (VAS)** — đúng tệp VAS ghim, nguồn gốc: <$($p.url)>",
    "",
    "- Tệp chạy: ``$binName`` — SHA-256 ``$($p.sha256.ToLowerInvariant())`` (khớp mã băm ghim trong bản phát hành VAS đã ký)",
    "- Giấy phép: $($p.license)",
    $(if ($p.home) { "- Trang chủ: <$($p.home)>" }),
    "- Mã nguồn tương ứng: các tệp ``nguon--…`` trong bản phát hành này ($($srcs.Count) tệp), danh sách mã băm ở ``SHA256SUMS.txt``",
    $(if ($gaps.Count) { "- Phần chưa xác định đủ: " + ($gaps -join "; ") }),
    "",
    "Yêu cầu mã nguồn: support@vietnews.com.vn"
) | Where-Object { $_ -ne $null }
[IO.File]::WriteAllLines($notes, $body, (New-Object Text.UTF8Encoding($false)))
if (-not $has) {
    & gh release create $tag --title "$($p.title) $($p.version)" --notes-file $notes $bin
    if ($LASTEXITCODE) { throw "Khong tao duoc ban phat hanh $tag" }
} elseif (-not ($existing -contains $binName)) {
    & gh release upload $tag $bin --clobber
    if ($LASTEXITCODE) { throw "Khong tai len duoc $binName" }
}
Remove-Item $bin -Force -ErrorAction SilentlyContinue

# ---- 4. mã nguồn + giấy phép: tải từng tệp → tải lên → xoá (đĩa máy chạy có hạn)
$i = 0
foreach ($s in @($srcs) + @($lic | ForEach-Object { [pscustomobject]@{ url = $_; what = "giay phep" } })) {
    $i++
    $isLic = $s.what -eq "giay phep"
    $leaf = [uri]::UnescapeDataString(([uri]$s.url).Segments[-1]).Trim('/')
    if (-not $leaf) { $leaf = "tep-$i" }
    if ($s.url -match 'github\.com/([^/]+)/([^/]+)/archive/') { $leaf = "$($Matches[2])-$leaf" }
    $name = ($isLic ? "giay-phep--" : "nguon--") + $leaf
    $safe = ($name -replace '[^A-Za-z0-9._+-]', '_')
    if ($existing -contains $safe) { $sums.Add("-  $safe (da co)"); continue }
    $asset = AssetName $name
    $f = Join-Path $work $asset
    if (-not (Fetch $s.url $f)) { $failed.Add("$($s.what): $($s.url)"); continue }
    $sums.Add("$(Sha $f)  $asset")
    & gh release upload $tag $f --clobber
    if ($LASTEXITCODE) { $failed.Add("tai len that bai $asset ($($s.url))") }
    Remove-Item $f -Force -ErrorAction SilentlyContinue
}

# ---- 5. mã băm + danh sách tải không được
$sf = Join-Path $work "SHA256SUMS.txt"
[IO.File]::WriteAllLines($sf, $sums, (New-Object Text.UTF8Encoding($false)))
& gh release upload $tag $sf --clobber
if ($failed.Count) {
    $ff = Join-Path $work "NGUON-CHUA-TAI-DUOC.txt"
    [IO.File]::WriteAllLines($ff, $failed, (New-Object Text.UTF8Encoding($false)))
    & gh release upload $tag $ff --clobber
    Write-Host "::warning::$tag : $($failed.Count) tep nguon / giay phep chua tai duoc (xem NGUON-CHUA-TAI-DUOC.txt) - chay lai workflow de bo sung"
}
Write-Host "Xong $tag : tep chay + $($srcs.Count) tep nguon ($($failed.Count) chua tai duoc)"
