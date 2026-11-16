# vas-tools

Phần mềm nguồn mở tích hợp trong **Vietnews AI Studio (VAS)** — Vietnews phân phối lại đúng bản VAS dùng (mã băm SHA-256 khớp bản phát hành VAS đã ký),
kèm mã nguồn tương ứng và giấy phép. Bộ cài VAS tải từ đây trước, lỗi thì tải từ nhà phát triển gốc.

| Phần mềm | Phiên bản | Giấy phép | Bản phát hành |
|---|---|---|---|
| Git for Windows (Git Bash cho Claude Code, mốc lưu dự án) | 2.56.0.2 | GPL-2.0 (Git); các thành phần MSYS2 / MinGW theo giấy phép riêng | [git-2.56.0.2](../../releases/tag/git-2.56.0.2) |
| Shotcut + melt (MLT) | 26.9.27 | GPL-3.0 (MLT: LGPL-2.1+) | [shotcut-26.9.27](../../releases/tag/shotcut-26.9.27) |
| Natron | 2.5.0 | GPL-2.0 | [natron-2.5.0](../../releases/tag/natron-2.5.0) |
| gltfpack (meshoptimizer) | 1.3 | MIT | [gltfpack-1.3](../../releases/tag/gltfpack-1.3) |
| yt-dlp (tải video YouTube khi người dùng đồng ý) | 2026.08.19 | Unlicense | [ytdlp-2026.08.19](../../releases/tag/ytdlp-2026.08.19) |
| 7-Zip (7zr — giải nén gói .7z) | 26.04 | LGPL-2.1-or-later (một phần BSD-3-Clause) | [7zr-26.04](../../releases/tag/7zr-26.04) |
| ImageMagick (xử lý ảnh bằng lệnh: cắt, ghép, chữ, đổi cỡ, chuyển định dạng) | 7.1.2-34 | ImageMagick License (kiểu Apache-2.0); thư viện đi kèm theo giấy phép riêng (NOTICE) | [imagemagick-7.1.2-34](../../releases/tag/imagemagick-7.1.2-34) |
| Thư viện chuẩn Python 3.11 cho Glaxnimate (bản standalone 0.6.0 của KDE thiếu python311.zip → xuất bằng lệnh sập; VAS chạy glaxnimate với PYTHONHOME trỏ vào đây) | 3.11.9 | PSF-2.0 | [glaxnimate-python-3.11.9](../../releases/tag/glaxnimate-python-3.11.9) |
| Inkscape (đồ hoạ vector: chữ, sơ đồ, đồ hoạ chuyển động; xuất PNG / PDF bằng lệnh) | 1.4.4 | GPL-3.0-or-later (thư viện đi kèm: LGPL / GPL / MIT…) | [inkscape-1.4.4](../../releases/tag/inkscape-1.4.4) |
| Krita (người dùng sửa ảnh, vẽ, tô màu ngay trên Desk) | 6.0.4.1 | GPL-3.0-or-later | [krita-6.0.4.1](../../releases/tag/krita-6.0.4.1) |
| Python 3.12 (bộ đo ảnh mẫu nhân vật) | 3.12.10 | PSF-2.0 | [python-3.12.10](../../releases/tag/python-3.12.10) |
| FluidSynth (trụ cột âm nhạc: render MIDI bằng bộ âm sắc SoundFont, không giao diện) | 2.6.1 | LGPL-2.1-or-later | [fluidsynth-2.6.1](../../releases/tag/fluidsynth-2.6.1) |
| MuseScore General (bộ âm sắc SoundFont General MIDI cho trụ cột âm nhạc) | 0.2.0 | MIT | [musescore-general-0.2.0](../../releases/tag/musescore-general-0.2.0) |
| 7-Zip (bản đầy đủ: giải nén bộ cài NSIS của LMMS / MuseScore — chỉ VAS dùng, không đăng ký cho AI) | 26.05 | LGPL-2.1-or-later + BSD-3-Clause; unRAR restriction | [7zip-26.05](../../releases/tag/7zip-26.05) |

Mỗi bản phát hành: tệp chạy gốc (không sửa), `nguon--…` mã nguồn tương ứng (theo danh mục `nguon/<id>.json`), `giay-phep--…`, `SHA256SUMS.txt`.
Bản phát hành do GitHub Actions tạo (`.github/workflows/publish.yml`): tải từ nguồn gốc, kiểm mã băm ghim, sai là không phát hành.

Bản quyền phần mềm thuộc các tác giả / cộng đồng của từng dự án. Yêu cầu mã nguồn: support@vietnews.com.vn
