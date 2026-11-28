#!/bin/sh
# Pasang llmy dari GitHub Release: https://ll.my.id
#   curl -fsSL https://ll.my.id/install.sh | sh
# LLMY_VERSION=v0.1.0   versi tertentu (bawaan: terbaru)
# LLMY_DIR=$HOME/bin    folder tujuan  (bawaan: ~/.local/bin)
set -eu

main() {
    repo=https://github.com/llm-y/agent/releases
    dir=${LLMY_DIR:-$HOME/.local/bin}

    case $(uname -s) in
        Linux) os=unknown-linux-musl ;;
        Darwin) os=apple-darwin ;;
        *) gagal "sistem $(uname -s) belum didukung" ;;
    esac
    case $(uname -m) in
        x86_64 | amd64) arch=x86_64 ;;
        aarch64 | arm64) arch=aarch64 ;;
        *) gagal "arsitektur $(uname -m) belum didukung" ;;
    esac
    file=llmy-$arch-$os.tar.gz
    if [ -n "${LLMY_VERSION:-}" ]; then
        url=$repo/download/v${LLMY_VERSION#v}
    else
        url=$repo/latest/download
    fi

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    echo "Mengunduh $file"
    unduh "$url/$file" "$tmp/$file"
    unduh "$url/SHA256SUMS" "$tmp/SHA256SUMS"
    (
        cd "$tmp"
        grep " $file\$" SHA256SUMS > cek || gagal "checksum untuk $file tidak ada"
        if command -v sha256sum > /dev/null; then
            sha256sum -c cek > /dev/null
        else
            shasum -a 256 -c cek > /dev/null
        fi
    ) || gagal "checksum tidak cocok; instalasi dibatalkan"

    tar -xzf "$tmp/$file" -C "$tmp"
    mkdir -p "$dir"
    # Ganti lewat rename: aman walau versi lama sedang berjalan.
    cp "$tmp/llmy" "$dir/.llmy.baru"
    chmod 755 "$dir/.llmy.baru"
    mv -f "$dir/.llmy.baru" "$dir/llmy"
    echo "Terpasang: $("$dir/llmy" --version) di $dir/llmy"

    case ":$PATH:" in
        *":$dir:"*) ;;
        *) echo "Tambahkan ke PATH: export PATH=\"$dir:\$PATH\"" ;;
    esac
    command -v git > /dev/null || echo "llmy membutuhkan git. Pasang dulu: sudo apt install git (Linux) atau xcode-select --install (macOS)"
    command -v ollama > /dev/null || echo "Ollama belum ada. Pasang dari https://ollama.com/download, lalu: ollama pull qwen3.5:9b"
}

unduh() {
    if command -v curl > /dev/null; then
        curl -fsSL --proto '=https' -o "$2" "$1" || gagal "tidak bisa mengunduh $1"
    elif command -v wget > /dev/null; then
        wget -q -O "$2" "$1" || gagal "tidak bisa mengunduh $1"
    else
        gagal "butuh curl atau wget"
    fi
}

gagal() {
    echo "install.sh: $1" >&2
    exit 1
}

# Di dalam fungsi, supaya unduhan yang terpotong tidak menjalankan separuh skrip.
main
