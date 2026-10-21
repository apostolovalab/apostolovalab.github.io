# Apostolova Lab website (GitHub Pages)

Static replacement for the Wix site <https://www.apostolovalab.com>, built with
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

## Step-by-step: put the website online

### Step 0 – Prerequisites (once)

- **R** (≥ 4.1) with **pandoc**. RStudio bundles pandoc; with Positron or plain R,
  install pandoc (<https://pandoc.org/installing.html>) or Quarto. Check in R:
  ```r
  rmarkdown::pandoc_available()   # must be TRUE
  ```
- **git** (`git --version`) and a **GitHub account**.
- Note: on a free GitHub plan, GitHub Pages only works for **public** repositories.

### Step 1 – Copy the images from the Wix site (once, while Wix is still online)

The pages currently fall back to the images hosted on Wix. To store them in the
repository instead, run from the project folder:

```bash
Rscript scripts/download_images.R
```

This fills `images/` (≈50 files, resized to max. 1600 px) and prints a summary.
Any failed download is listed with its URL; you can save that file manually into
`images/<path from data/images.csv>`.

### Step 2 – Build the site

```bash
Rscript build.R
```

(or open `apostolovalab-site.Rproj` in RStudio and press **Build Website**, then
run `build.R` once so `docs/.nojekyll` is created.)

Open `docs/index.html` in your browser to check the result.

### Step 3 – Create the GitHub repository

On GitHub: **+ → New repository**.

| Repository name          | Website address                          |
|--------------------------|------------------------------------------|
| `<account>.github.io`    | `https://<account>.github.io/`           |
| anything, e.g. `apostolovalab` | `https://<account>.github.io/apostolovalab/` |

`<account>` can be your user or (better for a lab) a GitHub **organization**,
e.g. `bcim-lab`. Choose **Public**, and do **not** add a README/.gitignore/licence
(the project already has them). Click **Create repository**.

### Step 4 – Push the project

In a terminal, inside the project folder (replace `<account>` and `<repo>`):

```bash
git init
git add .
git commit -m "Initial version of the lab website"
git branch -M main
git remote add origin https://github.com/<account>/<repo>.git
git push -u origin main
```

If git asks for a password, use a **personal access token**
(GitHub → Settings → Developer settings → Personal access tokens), or log in once
with the GitHub CLI: `gh auth login`.

### Step 5 – Turn on GitHub Pages

In the repository on GitHub:

1. **Settings → Pages** (left sidebar).
2. **Build and deployment → Source:** *Deploy from a branch*.
3. **Branch:** `main`, folder **`/docs`** → **Save**.
4. Wait 1–2 minutes. The page shows *"Your site is live at …"*; the
   **Actions** tab shows the deployment progress.

### Step 6 – Check the live site

Open the address from Step 5 and click through all pages (navigation, news posts,
mobile view). If you changed something, rebuild and push again (see *Updating*).

### Step 7 (optional) – Keep the domain `apostolovalab.com`

Only do this once the github.io version looks right.

1. In the project folder create a file named `CNAME` containing one line:
   ```
   www.apostolovalab.com
   ```
   then run `Rscript build.R` (it copies `CNAME` into `docs/`), commit and push.
2. GitHub → repository **Settings → Pages → Custom domain**: enter
   `www.apostolovalab.com` → **Save**.
3. At the domain's DNS provider (the registrar, or Wix → *Domains* if the domain
   was bought through Wix), set:

   | Type  | Host / name | Value                     |
   |-------|-------------|---------------------------|
   | CNAME | `www`       | `<account>.github.io`     |
   | A     | `@`         | `185.199.108.153`         |
   | A     | `@`         | `185.199.109.153`         |
   | A     | `@`         | `185.199.110.153`         |
   | A     | `@`         | `185.199.111.153`         |

   Remove the old records that point to Wix. DNS changes can take up to 24 h.
4. Back in **Settings → Pages**, tick **Enforce HTTPS** once it becomes available.
5. Recommended: verify the domain under your GitHub account/organization
   **Settings → Pages → Add a domain**, so nobody else can claim it.
6. Cancel the Wix plan only after the new site is live on the domain.

Reference: <https://docs.github.com/pages/configuring-a-custom-domain-for-your-github-pages-site>

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

