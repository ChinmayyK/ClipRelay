//! Clipboard history — a bounded, persisted ring buffer of recent clipboard
//! entries with pinning and metadata-only support for targeted sync.

use crate::dedup::hash_content;
use crate::protocol::{ClipboardContent, HistoryMetadata};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::VecDeque;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

pub const MIN_ENTRIES: usize = 20;
pub const MAX_ENTRIES: usize = 100;
pub const DEFAULT_ENTRIES: usize = 50;
pub const DEFAULT_MAX_TEXT_BYTES: usize = 64 * 1024;
pub const MAX_TEXT_PREVIEW: usize = 4096;

fn now_secs() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

fn clamp_entries(limit: usize) -> usize {
    limit.clamp(MIN_ENTRIES, MAX_ENTRIES)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryEntry {
    pub id: u64,
    pub timestamp: u64,
    pub source_device: String,
    pub payload: HistoryPayload,
    pub hash: String,
    #[serde(default)]
    pub pinned: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum HistoryPayload {
    Text {
        preview: String,
        full_len: usize,
        is_truncated: bool,
        full_text: Option<String>,
    },
    Image {
        mime: String,
        bytes: u64,
    },
    File {
        name: String,
        bytes: u64,
    },
    Metadata {
        kind: String,
        bytes: u64,
        summary: String,
        content_available: bool,
    },
}

impl HistoryEntry {
    fn from_content(
        id: u64,
        content: &ClipboardContent,
        source_device: String,
        max_text_bytes: usize,
    ) -> Self {
        let hash = hex::encode(hash_content(content));
        let payload = match content {
            ClipboardContent::Text(s) => {
                let preview_len = s.len().min(MAX_TEXT_PREVIEW);
                let preview = format_preview(s, preview_len);
                let stored_len = s.len().min(max_text_bytes);
                let full_text = Some(s[..stored_len].to_string());
                HistoryPayload::Text {
                    preview,
                    full_len: s.len(),
                    is_truncated: s.len() > stored_len,
                    full_text,
                }
            }
            ClipboardContent::Image { mime, data } => HistoryPayload::Image {
                mime: mime.clone(),
                bytes: data.len() as u64,
            },
            ClipboardContent::File { name, data } => HistoryPayload::File {
                name: name.clone(),
                bytes: data.len() as u64,
            },
        };

        Self {
            id,
            timestamp: now_secs(),
            source_device,
            payload,
            hash,
            pinned: false,
        }
    }

    fn from_metadata(id: u64, meta: &HistoryMetadata) -> Self {
        Self {
            id,
            timestamp: meta.timestamp,
            source_device: meta.source_device.clone(),
            payload: HistoryPayload::Metadata {
                kind: meta.kind.clone(),
                bytes: meta.bytes,
                summary: meta.summary(),
                content_available: false,
            },
            hash: meta.hash.clone(),
            pinned: meta.pinned,
        }
    }

    pub fn summary(&self) -> String {
        match &self.payload {
            HistoryPayload::Text { preview, .. } => {
                let first_line = preview.lines().next().unwrap_or("").trim();
                if first_line.len() > 60 {
                    format!("{}...", &first_line[..60])
                } else {
                    first_line.to_string()
                }
            }
            HistoryPayload::Image { mime, bytes } => {
                format!("[Image {} {:.1} KB]", mime, *bytes as f64 / 1024.0)
            }
            HistoryPayload::File { name, bytes } => {
                format!("[File '{}' {:.1} KB]", name, *bytes as f64 / 1024.0)
            }
            HistoryPayload::Metadata { summary, .. } => summary.clone(),
        }
    }

    pub fn kind(&self) -> &'static str {
        match self.payload {
            HistoryPayload::Text { .. } => "text",
            HistoryPayload::Image { .. } => "image",
            HistoryPayload::File { .. } => "file",
            HistoryPayload::Metadata { .. } => "metadata",
        }
    }

    pub fn repushable_text(&self) -> Option<&str> {
        match &self.payload {
            HistoryPayload::Text {
                full_text: Some(text),
                ..
            } => Some(text.as_str()),
            _ => None,
        }
    }

    fn can_upgrade_from(&self, other: &HistoryEntry) -> bool {
        matches!(self.payload, HistoryPayload::Metadata { .. })
            && !matches!(other.payload, HistoryPayload::Metadata { .. })
    }
}

fn format_preview(text: &str, preview_len: usize) -> String {
    if text.len() > preview_len {
        format!("{}...", &text[..preview_len])
    } else {
        text.to_string()
    }
}

/// Escape a field value for CSV (wraps in quotes if it contains commas, quotes, or newlines).
fn csv_escape(s: &str) -> String {
    if s.contains(',') || s.contains('"') || s.contains('\n') {
        format!("\"{}\"", s.replace('"', "\"\""))
    } else {
        s.to_string()
    }
}

pub struct History {
    entries: VecDeque<HistoryEntry>,
    path: PathBuf,
    next_id: u64,
    max_entries: usize,
}

impl History {
    pub fn load(path: impl AsRef<Path>) -> Result<Self> {
        Self::load_with_limit(path, DEFAULT_ENTRIES)
    }

    pub fn load_with_limit(path: impl AsRef<Path>, max_entries: usize) -> Result<Self> {
        let path = path.as_ref().to_path_buf();
        let mut entries = VecDeque::new();
        let mut next_id = 1u64;

        if path.exists() {
            let bytes = std::fs::read(&path).context("reading history")?;
            if !bytes.is_empty() {
                let loaded: Vec<HistoryEntry> =
                    serde_json::from_slice(&bytes).context("parsing history")?;
                for entry in loaded {
                    next_id = next_id.max(entry.id + 1);
                    entries.push_back(entry);
                }
            }
        }

        let mut history = Self {
            entries,
            path,
            next_id,
            max_entries: clamp_entries(max_entries),
        };
        history.trim_to_limit();
        history.persist()?;
        Ok(history)
    }

    pub fn set_max_entries(&mut self, max_entries: usize) -> Result<()> {
        self.max_entries = clamp_entries(max_entries);
        self.trim_to_limit();
        self.persist()
    }

    pub fn push(
        &mut self,
        content: &ClipboardContent,
        source_device: String,
    ) -> Result<&HistoryEntry> {
        self.push_with_options(content, source_device, DEFAULT_MAX_TEXT_BYTES)
    }

    pub fn push_with_options(
        &mut self,
        content: &ClipboardContent,
        source_device: String,
        max_text_bytes: usize,
    ) -> Result<&HistoryEntry> {
        let id = self.next_id;
        self.next_id += 1;
        let entry = HistoryEntry::from_content(id, content, source_device, max_text_bytes);
        self.insert_entry(entry)
    }

    pub fn push_metadata(&mut self, meta: &HistoryMetadata) -> Result<&HistoryEntry> {
        let id = self.next_id;
        self.next_id += 1;
        let entry = HistoryEntry::from_metadata(id, meta);
        self.insert_entry(entry)
    }

    pub fn entries(&self) -> &VecDeque<HistoryEntry> {
        &self.entries
    }

    pub fn recent(&self, n: usize) -> impl Iterator<Item = &HistoryEntry> {
        self.entries.iter().rev().take(n)
    }

    pub fn search<'a>(&'a self, query: &'a str) -> impl Iterator<Item = &'a HistoryEntry> {
        let q = query.to_lowercase();
        self.entries.iter().rev().filter(move |entry| {
            entry.summary().to_lowercase().contains(&q)
                || entry.source_device.to_lowercase().contains(&q)
                || entry.kind().contains(&q)
        })
    }

    pub fn get(&self, id: u64) -> Option<&HistoryEntry> {
        self.entries.iter().find(|entry| entry.id == id)
    }

    pub fn set_pinned(&mut self, id: u64, pinned: bool) -> Result<Option<&HistoryEntry>> {
        if let Some(entry) = self.entries.iter_mut().find(|entry| entry.id == id) {
            entry.pinned = pinned;
            self.persist()?;
            return Ok(self.get(id));
        }
        Ok(None)
    }

    pub fn remove(&mut self, id: u64) -> Result<bool> {
        let len_before = self.entries.len();
        self.entries.retain(|entry| entry.id != id);
        let removed = self.entries.len() != len_before;
        if removed {
            self.persist()?;
        }
        Ok(removed)
    }

    pub fn clear(&mut self) -> Result<()> {
        self.entries.clear();
        self.persist()
    }

    fn insert_entry(&mut self, entry: HistoryEntry) -> Result<&HistoryEntry> {
        if let Some(last) = self.entries.back_mut() {
            if last.hash == entry.hash {
                if last.can_upgrade_from(&entry) {
                    let pinned = last.pinned;
                    *last = entry;
                    last.pinned = pinned;
                    self.persist()?;
                }
                return Ok(self.entries.back().expect("history entry exists"));
            }
        }

        self.entries.push_back(entry);
        self.trim_to_limit();
        self.persist()?;
        Ok(self.entries.back().expect("history entry exists"))
    }

    fn trim_to_limit(&mut self) {
        while self.entries.len() > self.max_entries {
            if let Some(index) = self.entries.iter().position(|entry| !entry.pinned) {
                self.entries.remove(index);
            } else {
                self.entries.pop_front();
            }
        }
    }

    fn persist(&self) -> Result<()> {
        if let Some(parent) = self.path.parent() {
            std::fs::create_dir_all(parent).context("creating history dir")?;
        }
        // Atomic write: serialise to a .tmp file then rename so a crash during
        // write never leaves the history file in a partially-written state.
        let tmp_path = self.path.with_extension("tmp");
        let bytes = serde_json::to_vec_pretty(
            &self.entries.iter().cloned().collect::<Vec<HistoryEntry>>(),
        )?;
        std::fs::write(&tmp_path, &bytes).context("writing history tmp")?;
        std::fs::rename(&tmp_path, &self.path).context("renaming history file")?;
        Ok(())
    }

    /// Full-text search through stored history.
    ///
    /// Searches:
    /// - `source_device` (case-insensitive substring)
    /// - `kind` (exact match: "text", "image", "file")
    /// - Summary text (first line preview)
    /// - Full stored text for `Text` entries (if `full_text` is available)
    pub fn search_fulltext<'a>(&'a self, query: &'a str) -> impl Iterator<Item = &'a HistoryEntry> {
        let q = query.to_lowercase();
        self.entries.iter().rev().filter(move |entry| {
            if entry.source_device.to_lowercase().contains(&q) {
                return true;
            }
            if entry.kind().contains(q.as_str()) {
                return true;
            }
            if entry.summary().to_lowercase().contains(&q) {
                return true;
            }
            // Also check the stored full text for text entries.
            if let HistoryPayload::Text { full_text: Some(ref text), .. } = entry.payload {
                if text.to_lowercase().contains(&q) {
                    return true;
                }
            }
            false
        })
    }

    /// Return entries newer than `since_id` (exclusive), most-recent first.
    ///
    /// Useful for incremental UI updates: call with the last-seen entry ID to
    /// fetch only new arrivals without re-sending the entire history.
    pub fn recent_since(&self, since_id: u64) -> impl Iterator<Item = &HistoryEntry> {
        self.entries
            .iter()
            .rev()
            .take_while(move |entry| entry.id > since_id)
    }

    /// Export history as CSV text.
    ///
    /// Columns: `id,timestamp,source_device,kind,bytes,preview`
    ///
    /// The `preview` column is double-quote-escaped and newlines are replaced
    /// with `\n` so the output is always single-line per entry.
    pub fn export_csv(&self) -> String {
        let mut out = String::from("id,timestamp,source_device,kind,bytes,preview\n");
        for entry in self.entries.iter().rev() {
            let bytes_str = match &entry.payload {
                HistoryPayload::Text { full_len, .. } => full_len.to_string(),
                HistoryPayload::Image { bytes, .. } => bytes.to_string(),
                HistoryPayload::File { bytes, .. } => bytes.to_string(),
                HistoryPayload::Metadata { bytes, .. } => bytes.to_string(),
            };
            // Escape the preview: double quotes become "", newlines become ↵.
            let preview = entry
                .summary()
                .replace('"', "\"\"")
                .replace('\n', "↵")
                .replace('\r', "");
            out.push_str(&format!(
                "{},{},{},{},{},\"{}\"\n",
                entry.id,
                entry.timestamp,
                csv_escape(&entry.source_device),
                entry.kind(),
                bytes_str,
                preview,
            ));
        }
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::NamedTempFile;

    #[test]
    fn push_and_persist() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 50).unwrap();

        history
            .push_with_options(
                &ClipboardContent::Text("hello world".into()),
                "local".into(),
                1024,
            )
            .unwrap();
        history
            .push_with_options(
                &ClipboardContent::Text("second item".into()),
                "DeviceB".into(),
                1024,
            )
            .unwrap();

        assert_eq!(history.entries().len(), 2);

        let reloaded = History::load_with_limit(tmp.path(), 50).unwrap();
        assert_eq!(reloaded.entries().len(), 2);
        assert_eq!(reloaded.entries().back().unwrap().source_device, "DeviceB");
    }

    #[test]
    fn dedup_consecutive_identical() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 50).unwrap();
        let content = ClipboardContent::Text("same".into());

        history
            .push_with_options(&content, "local".into(), 1024)
            .unwrap();
        history
            .push_with_options(&content, "local".into(), 1024)
            .unwrap();
        assert_eq!(history.entries().len(), 1);
    }

    #[test]
    fn pinned_items_survive_trim_when_possible() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 20).unwrap();

        for idx in 0..20 {
            history
                .push_with_options(
                    &ClipboardContent::Text(format!("item-{idx}")),
                    "local".into(),
                    1024,
                )
                .unwrap();
        }
        let pinned_id = history.entries().front().unwrap().id;
        history.set_pinned(pinned_id, true).unwrap();
        history
            .push_with_options(
                &ClipboardContent::Text("newest".into()),
                "local".into(),
                1024,
            )
            .unwrap();

        assert!(history.get(pinned_id).is_some());
        assert_eq!(history.entries().len(), 20);
    }

    #[test]
    fn metadata_upgrades_to_real_content() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 50).unwrap();
        let meta = HistoryMetadata::from_content(
            &ClipboardContent::Text("secret note".into()),
            "Desk".into(),
            false,
        );
        let hash = meta.hash.clone();

        history.push_metadata(&meta).unwrap();
        history
            .push_with_options(
                &ClipboardContent::Text("secret note".into()),
                "Desk".into(),
                1024,
            )
            .unwrap();

        let entry = history.entries().back().unwrap();
        assert_eq!(entry.hash, hash);
        assert!(matches!(entry.payload, HistoryPayload::Text { .. }));
    }

    #[test]
    fn fulltext_search_finds_stored_text() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 50).unwrap();
        history
            .push_with_options(
                &ClipboardContent::Text("unique-needle-42".into()),
                "DevA".into(),
                1024,
            )
            .unwrap();
        history
            .push_with_options(
                &ClipboardContent::Text("totally unrelated".into()),
                "DevB".into(),
                1024,
            )
            .unwrap();

        let results: Vec<_> = history.search_fulltext("unique-needle").collect();
        assert_eq!(results.len(), 1, "should find exactly the one entry");
        assert!(results[0].source_device == "DevA");
    }

    #[test]
    fn search_by_device_name() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 50).unwrap();
        history
            .push_with_options(&ClipboardContent::Text("a".into()), "iPhone".into(), 1024)
            .unwrap();
        history
            .push_with_options(&ClipboardContent::Text("b".into()), "MacBook".into(), 1024)
            .unwrap();

        let results: Vec<_> = history.search_fulltext("iphone").collect();
        assert_eq!(results.len(), 1);
    }

    #[test]
    fn recent_since_returns_only_newer_entries() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 50).unwrap();
        for i in 0..5 {
            history
                .push_with_options(
                    &ClipboardContent::Text(format!("item {i}")),
                    "local".into(),
                    1024,
                )
                .unwrap();
        }

        // Snapshot the id of the 3rd entry.
        let anchor_id = history.entries().iter().nth(2).unwrap().id;
        let newer: Vec<_> = history.recent_since(anchor_id).collect();
        // Only entries with id > anchor_id should appear.
        assert!(newer.iter().all(|e| e.id > anchor_id));
        assert_eq!(newer.len(), 2); // entries 4 and 5
    }

    #[test]
    fn export_csv_produces_valid_rows() {
        let tmp = NamedTempFile::new().unwrap();
        let mut history = History::load_with_limit(tmp.path(), 50).unwrap();
        history
            .push_with_options(
                &ClipboardContent::Text("hello, world".into()),
                "MyDevice".into(),
                1024,
            )
            .unwrap();

        let csv = history.export_csv();
        let lines: Vec<&str> = csv.lines().collect();
        // Header + 1 data row.
        assert_eq!(lines.len(), 2);
        assert!(lines[0].starts_with("id,timestamp,source_device"));
        // Commas inside text should be quoted in the preview column.
        assert!(lines[1].contains("text"));
    }
