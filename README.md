# Apostolova Lab website (GitHub Pages)

Static replacement for the Wix site, built with
**R Markdown** (`rmarkdown::render_site`). Each page is an `.Rmd` source file;
the rendered HTML goes to `docs/`, which GitHub Pages serves as-is.

---

## Project structure

```
apostolovalab-site/
├── _site.yml                 # site config: output dir (docs/), theme, CSS, includes
├── _navbar.html              # top navigation bar (logo + menu)
├── _includes/
│   ├── head.html             # fonts, favicon, meta description
│   └── footer.html           # footer line
├── index.Rmd                 # Home
├── research.Rmd              # Research
├── publications.Rmd          # Publications (generated from data/publications.yml)
├── key-publications.Rmd      # Key publications (data/key_publications.yml)
├── team.Rmd                  # Team (data/team.yml)
├── news.Rmd                  # News overview (data/news.yml)
├── post-*.Rmd                # one file per news post
├── fundings.Rmd              # Funding (data/funders.yml)
├── find-contact-us.Rmd       # Find & Contact Us
├── data/
│   ├── images.csv            # every image: key, local file, original Wix URL
│   ├── team.yml  publications.yml  key_publications.yml  news.yml  funders.yml
├── R/helpers.R               # shared R functions (cards, lists, images)
├── assets/                   # style.css, favicon.svg
├── images/                   # local images (filled by scripts/download_images.R)
├── post/                     # redirects so old Wix links /post/<slug> keep working
├── scripts/download_images.R # one-off: copy all images from the Wix site
├── build.R                   # renders everything into docs/
└── docs/                     # <- rendered website (this is what GitHub Pages publishes)
```

Page file names match the old Wix URLs (`/research`, `/team`, `/fundings`,
`/find-contact-us`, ...), so existing links keep working once the domain points
to GitHub Pages (GitHub serves `team.html` at `/team` as well).

---



## Updating the website

Every change follows the same loop:

```bash
# 1. edit .Rmd / data/*.yml / assets/style.css
Rscript build.R                 # 2. rebuild docs/
git add .                       # 3. publish
git commit -m "Describe the change"
git push
```

GitHub Pages updates within a couple of minutes.

**Common edits**

- **New publication** – add an entry to `data/publications.yml` (any order; the
  list is grouped by year automatically; *Apostolova P* is bolded automatically).
- **New team member** – put the photo in `images/team/`, add a line to
  `data/images.csv` (`key,file,url` – leave `url` empty), then add the person to
  `data/team.yml` with `photo: <key>`. Former members go under `alumni:`.
- **New news post** – copy a `post-*.Rmd` file, edit title/date/text, add its
  image(s) to `images/news/` + `data/images.csv`, and add an entry to
  `data/news.yml` (`page: post-<name>.html`). The 3 newest posts appear on the
  home page automatically.
- **New page** – create `newpage.Rmd` (copy the YAML header and setup chunk from
  an existing page) and add `<li><a href="newpage.html">…</a></li>` to `_navbar.html`.
- **Colours / fonts** – the variables at the top of `assets/style.css`.

---

