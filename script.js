import { getJSON } from "https://cdn.jsdelivr.net/gh/crootjs/lib@0.0.41/api.min.js";
import { onClicks, setInnerText } from "https://cdn.jsdelivr.net/gh/crootjs/lib@0.0.41/element.min.js";
import { initTabs } from "https://cdn.jsdelivr.net/gh/crootjs/lib@0.0.41/tabs.min.js";
import { toastError, toastSuccess } from "https://cdn.jsdelivr.net/gh/crootjs/lib@0.0.41/toast.min.js";

const tabs = initTabs("tab-sistem");
if (navigator.userAgent.includes("Windows")) tabs.select(1);

onClicks("salin", (button) => {
    const text = button.parentElement.querySelector("code").textContent;
    navigator.clipboard.writeText(text).then(
        () => toastSuccess("Perintah disalin."),
        // Ditolak kalau browser tidak memberi izin clipboard
        () => toastError("Tidak bisa menyalin. Pilih teksnya lalu salin manual."),
    );
});

// Kalau gagal (misalnya batas permintaan GitHub), tulisan "terbaru" di HTML tetap tampil.
getJSON("https://api.github.com/repos/llm-y/agent/releases/latest", ({ status, data }) => {
    if (status === 200 && data?.tag_name) setInnerText("versi", data.tag_name);
});
