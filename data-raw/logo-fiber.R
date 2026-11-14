# Generate the fiber hex-sticker logo (man/figures/logo.png).
#
# Concept: two white-matter fiber bundles crossing — the archetypal diffusion-MRI
# "crossing fibers" scenario. Two symmetric populations of curving streamlines
# cross at the center; a small translucent two-lobe "microstructure" glyph (two
# ellipses, one aligned with each bundle direction) sits at the crossing voxel,
# depicting the two local orientations present there. Wordmark "fiber" sits
# below, clear of the art.
#
# Colour rationale: the two crossing populations are encoded with a warm hue
# (coral, going up-right) vs a cool hue (teal, going up-left). Warm-vs-cool
# hue contrast is the standard device in diffusion-MRI crossing-fibre figures
# for visually disambiguating distinct populations; pure DTI axial hairpin
# colouring (R=X, G=Y, B=Z) cannot separate a symmetric X of directions because
# both arms render as near-identical green-yellow. The art sits on a dark
# background so the two saturated hues pop while the translucent white glyph
# reads as "structure", not background.
#
# Re-run with: source("data-raw/logo-fiber.R")
library(hexSticker)
library(ggplot2)

# Write the finished sticker directly into the package (deterministic, no
# interactive overwrite prompt). usethis::use_logo() resizes to the 240x278
# standard for pkgdown websites; the README already links man/figures/logo.png.
logo_path <- file.path("man", "figures", "logo.png")

# --- palette ---------------------------------------------------------------
bg_fill   <- "#141a2a" # deep navy background
bg_border <- "#000000"
col_warm  <- "#ef7f5f" # coral  — bundle going up-right (theta = 50 deg)
col_cool  <- "#3fc3e0" # teal   — bundle going up-left  (theta = 130 deg)
glyph_fill <- "#ffffff"

# --- one symmetric bundle of crossing streamlines, centered at (0.5, 0.5) ----
# Builds nstr curved streamlines fanning along `theta_deg`; `offsets` gives the
# perpendicular jitter per streamline and `curv` bows each one gently so the
# bundle fans symmetrically about the centre.
C <- c(0.5, 0.5)

mk_bundle2 <- function(theta_deg, offsets, curv = 0.03, n = 200) {
  th <- theta_deg * pi / 180
  v <- c(cos(th), sin(th))
  n_ <- c(-sin(th), cos(th))
  L <- 0.46
  p <- seq(-L, L, length.out = n)
  do.call(rbind, lapply(seq_along(offsets), function(j) {
    q0 <- offsets[j]
    q  <- q0 + curv * (p / L)^2        # per-streamline perpendicular bow
    px <- C[1] + p * v[1] + q * n_[1]
    py <- C[2] + p * v[2] + q * n_[2]
    data.frame(x = px, y = py, tract = j)
  }))
}

offsets <- seq(-0.3, 0.3, length.out = 7)
bA <- mk_bundle2(50, offsets)   # up-right
bB <- mk_bundle2(130, offsets)  # up-left

# --- crossed microstructure glyph: two ellipses at the crossing voxel --------
mk_ellipse <- function(cx, cy, angle, rx, ry, n = 120) {
  a <- seq(0, 2 * pi, length.out = n)
  data.frame(
    x = cx + rx * cos(a) * cos(angle) - ry * sin(a) * sin(angle),
    y = cy + rx * cos(a) * sin(angle) + ry * sin(a) * cos(angle)
  )
}
# angle is in radians; 50 and 130 degrees, aligned with each bundle
eA <- mk_ellipse(0.5, 0.5, 50 * pi / 180, 0.20, 0.075)
eB <- mk_ellipse(0.5, 0.5, 130 * pi / 180, 0.20, 0.075)

# --- icon -------------------------------------------------------------------
icon <- ggplot() +
  geom_line(
    data = bA, aes(x, y, group = tract),
    color = col_warm, linewidth = 1.5, lineend = "round"
  ) +
  geom_line(
    data = bB, aes(x, y, group = tract),
    color = col_cool, linewidth = 1.5, lineend = "round"
  ) +
  # translucent white glyph over the crossing so the fibres read through it
  geom_polygon(data = eA, aes(x, y), fill = glyph_fill, alpha = 0.30, color = NA) +
  geom_polygon(data = eB, aes(x, y), fill = glyph_fill, alpha = 0.30, color = NA) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "transparent", color = NA)
  )

# --- write icon, compose sticker ---------------------------------------------
icon_path <- tempfile(fileext = ".png")
ggsave(icon_path, icon, width = 6, height = 6, dpi = 150, bg = "transparent")

sticker(
  subplot = icon_path,
  package = "fiber",
  p_size   = 24,
  p_color  = "#ffffff",
  p_y      = 0.40,
  p_family = "sans",
  s_x      = 1,
  s_y      = 1.15,
  s_width  = 0.90,
  s_height = 0.90,
  h_fill   = bg_fill,
  h_color  = bg_border,
  h_size   = 1.1,
  filename = logo_path,
  white_around_sticker = TRUE
)
