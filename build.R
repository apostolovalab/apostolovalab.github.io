# =============================================================================
# build.R -- render the whole website into docs/
# Usage (from the project folder):   Rscript build.R
#        or in RStudio/Positron:     source("build.R")
# =============================================================================

# ---- Packages ---------------------------------------------------------------
needed <- c("rmarkdown", "knitr", "yaml", "htmltools")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing)

# ---- Render -----------------------------------------------------------------
rmarkdown::clean_site(preview = FALSE)
rmarkdown::render_site(encoding = "UTF-8")

# ---- GitHub Pages extras ----------------------------------------------------
# .nojekyll: serve docs/ as plain static files (no Jekyll processing)
file.create(file.path("docs", ".nojekyll"))

# CNAME: only if you use a custom domain (see README, step 7)
if (file.exists("CNAME")) file.copy("CNAME", file.path("docs", "CNAME"), overwrite = TRUE)

message("\nDone. Open docs/index.html in a browser to preview.")
