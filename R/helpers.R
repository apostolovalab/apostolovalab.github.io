# =============================================================================
# helpers.R -- shared functions sourced by every .Rmd page
# Dependencies: yaml, htmltools (both installed with rmarkdown)
# =============================================================================

suppressPackageStartupMessages({
  library(yaml)
  library(htmltools)
})

# ---- Data loading -----------------------------------------------------------

read_data <- function(name) {
  yaml::read_yaml(file.path("data", paste0(name, ".yml")), fileEncoding = "UTF-8")
}

image_manifest <- utils::read.csv("data/images.csv", stringsAsFactors = FALSE,
                                  na.strings = "")

# ---- Images -----------------------------------------------------------------
# Every image points to its local copy in images/. Until
# scripts/download_images.R has been run, the browser falls back to the
# original Wix-hosted file (onerror handler), so pages work either way.

img_tag <- function(key, alt = "", class = NULL, ...) {
  row <- image_manifest[image_manifest$key == key, ]
  if (nrow(row) != 1) stop("Unknown image key: ", key, call. = FALSE)
  fallback <- if (!is.na(row$url))
    sprintf("this.onerror=null;this.src='%s';", row$url) else NULL
  tags$img(src = file.path("images", row$file), alt = alt, class = class,
           loading = "lazy", onerror = fallback, ...)
}

# Character version, for inline `r img_html(...)` use inside Markdown text
img_html <- function(...) as.character(img_tag(...))

# ---- Text helpers -----------------------------------------------------------

# Bold the PI's name (incl. maiden name) in author strings
bold_pi <- function(authors) {
  authors <- htmlEscape(authors)
  HTML(gsub("((Apostolova|Chernogorova) P\\*?)", "<strong>\\1</strong>", authors))
}

fmt_date <- function(d) format(as.Date(d), "%b %d, %Y")

# ---- Page components ---------------------------------------------------------

# Beige "label" box with a line through it (section titles like "News")
section_label <- function(text) {
  div(class = "section-label", span(text))
}

# News card used on the home page and the news page
news_card <- function(post) {
  a(class = "news-card", href = post$page,
    div(class = "news-thumb", img_tag(post$thumb, alt = post$title)),
    div(class = "news-body",
        div(class = "news-meta", fmt_date(post$date)),
        h3(class = "news-title", toupper(post$title)),
        if (!is.null(post$summary)) p(post$summary)))
}

news_grid <- function(n = Inf) {
  posts <- read_data("news")$posts
  posts <- posts[order(as.Date(vapply(posts, `[[`, "", "date")), decreasing = TRUE)]
  posts <- utils::head(posts, n)
  div(class = "news-grid", lapply(posts, news_card))
}

# ---- Link icons (Font Awesome 7, loaded in _includes/head.html) -------------
# Icon chosen from the link label (case-insensitive). Override per link with
# `icon:` in team.yml, e.g. icon: "fa-solid fa-flask". Unknown labels get a
# generic link icon. Icon names: https://fontawesome.com/icons (free set).
link_icons <- c(
  "linkedin"       = "fa-brands fa-linkedin",
  "google scholar" = "fa-brands fa-google-scholar",
  "scholar"        = "fa-brands fa-google-scholar",
  "orcid"          = "fa-brands fa-orcid",
  "github"         = "fa-brands fa-github",
  "researchgate"   = "fa-brands fa-researchgate",
  "twitter"        = "fa-brands fa-x-twitter",
  "x"              = "fa-brands fa-x-twitter",
  "bluesky"        = "fa-brands fa-bluesky",
  "website"        = "fa-solid fa-globe",
  "email"          = "fa-solid fa-envelope"
)

link_icon <- function(l) {
  cls <- l$icon %||% unname(link_icons[tolower(l$label)])
  if (is.na(cls)) cls <- "fa-solid fa-link"
  tags$i(class = cls, `aria-hidden` = "true")
}

# Team member card
team_card <- function(m) {
  full_name <- trimws(paste(if (is.null(m$title)) "" else m$title, m$name))
  links <- if (length(m$links))
    p(class = "member-links",
      lapply(m$links, function(l)
        a(href = l$url, target = "_blank", rel = "noopener", link_icon(l), l$label)))
  div(class = "member-card",
      img_tag(m$photo, alt = m$name, class = "member-photo",
        # optional per-person crop from team.yml (e.g. photo_position: "center 30%")
        style = if (!is.null(m$photo_position)) paste0("object-position: ", m$photo_position, ";")),
      div(class = "member-text",
          h3(full_name),
          div(class = "member-role", m$role),
          p(m$bio),
          links))
}

# Publication list grouped by year (newest first)
publication_list <- function() {
  pubs  <- read_data("publications")$publications
  years <- sort(unique(vapply(pubs, function(p) as.integer(p$year), 1L)), decreasing = TRUE)
  tagList(lapply(years, function(y) {
    in_year <- Filter(function(p) as.integer(p$year) == y, pubs)
    div(class = "pub-year",
        h2(id = paste0("y", y), y),
        tags$ol(class = "pub-list", lapply(in_year, function(p) {
          # optional "Read more..." link to the matching Key publications card
          read_more <- if (!is.null(p$read_more))
            tagList(" ", a(class = "pub-more",
                           href = paste0("key-publications.html#", p$read_more),
                           "Read more..."))
          tags$li(
            a(class = "pub-title", href = p$url, target = "_blank", rel = "noopener", p$title),
            div(class = "pub-authors", bold_pi(p$authors)),
            if (!is.null(p$note)) div(class = "pub-note", p$note),
            div(class = "pub-journal", paste0(p$journal, ". ", p$date, "."), read_more))
        })))
  }))
}


         
          


# Key publications -- layout mirrors the original Wix page:
# title / authors / note / journal line, then the summary text wrapping
# around a large image, then the article link.
# Authors, note, journal and date are taken from data/publications.yml
# (the entry whose read_more matches this image key); any of these fields
# set directly in key_publications.yml take precedence.
key_pub_cards <- function() {
  kps  <- read_data("key_publications")$key_publications
  pubs <- read_data("publications")$publications
  tagList(lapply(kps, function(k) {
    pub   <- Find(function(p) identical(p$read_more, k$image), pubs)   # NULL if none
    get   <- function(field) k[[field]] %||% pub[[field]]
    paras <- strsplit(trimws(k$summary), "\n+")[[1]]                  # one <p> per paragraph
    side  <- if (identical(k$image_side, "left")) "img-left" else "img-right"
    div(class = "keypub", id = k$image,   # anchor target for "Read more..." links
        div(class = "keypub-title", sub("\\.$", "", get("title"))),
        div(class = "keypub-meta", bold_pi(get("authors"))),
        if (!is.null(get("note"))) div(class = "keypub-meta", get("note")),
        div(class = "keypub-meta",
           HTML(paste0("<strong>", htmlEscape(get("journal")), "</strong>. ", htmlEscape(get("date"))))),
        div(class = "keypub-body",
            img_tag(k$image, alt = get("title"), class = paste("keypub-img", side)),
            lapply(paras, p),
            p(class = "keypub-link",
              a(href = k$url, target = "_blank", rel = "noopener", k$url))))
  }))
}
# Funder logo grid

funder_grid <- function() {
  fs <- read_data("funders")$funders
  div(class = "funder-grid", lapply(fs, function(f) {
    logo <- img_tag(f$logo, alt = paste("Logo", f$name))
    if (nzchar(f$url %||% "")) a(class = "funder", href = f$url, target = "_blank", rel = "noopener", title = f$name, logo)
    else div(class = "funder", title = f$name, logo)
  }))
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# Image gallery (e.g. for news posts)
# Each thumbnail links to its full-size image; assets/lightbox.js opens that
# link in an on-page viewer (without JavaScript, the image opens on its own).
gallery <- function(keys, alt = "") {
  div(class = "gallery", lapply(keys, function(k) {
    file <- image_manifest$file[image_manifest$key == k]
    a(class = "lightbox-link", href = file.path("images", file), img_tag(k, alt = alt))
  }))
}