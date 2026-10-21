# =============================================================================
# download_images.R -- copy all images from the old Wix site into images/
#
# Run ONCE from the project folder, while the Wix site is still online:
#     Rscript scripts/download_images.R
# then rebuild:  Rscript build.R
#
# Images are listed in data/images.csv (key, local file, original URL).
# Wix serves a resized copy (max 1600 px) to keep the repository small;
# if that fails the original file is downloaded instead.
# Already-downloaded files are skipped, so the script can be re-run safely.
# =============================================================================

manifest <- utils::read.csv("data/images.csv", stringsAsFactors = FALSE, na.strings = "")
manifest <- manifest[!is.na(manifest$url), ]

# ---- Helpers ----------------------------------------------------------------
resized_url <- function(url, max_px = 1600) {
  id <- basename(url)
  sprintf("%s/v1/fit/w_%d,h_%d,q_90/%s", url, max_px, max_px, id)
}

fetch <- function(url, dest) {
  ok <- tryCatch({
    utils::download.file(url, dest, mode = "wb", quiet = TRUE)
    file.exists(dest) && file.size(dest) > 0
  }, error = function(e) FALSE, warning = function(w) FALSE)
  if (!ok && file.exists(dest)) unlink(dest)
  ok
}

# ---- Download loop ----------------------------------------------------------
status <- vapply(seq_len(nrow(manifest)), function(i) {
  dest <- file.path("images", manifest$file[i])
  if (file.exists(dest)) return("exists")
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  # avif/webp: keep the original (no resize) to preserve the format
  ext <- tolower(tools::file_ext(dest))
  if (!ext %in% c("avif", "webp") && fetch(resized_url(manifest$url[i]), dest)) return("resized")
  if (fetch(manifest$url[i], dest)) return("original")
  "FAILED"
}, character(1))

print(table(status))
if (any(status == "FAILED")) {
  message("Failed downloads:")
  print(manifest[status == "FAILED", c("key", "url")], row.names = FALSE)
}
