library(hexSticker)
library(ggplot2)

set.seed(7421)

# ── 1.  Helper functions ──────────────────────────────────────────────────────

# n points on an elliptical arc (clockwise when a_from > a_to)
arc_pts <- function(cx, cy, rx, ry, a_from, a_to, n = 48) {
  a <- seq(a_from, a_to, length.out = n)
  cbind(cx + rx * cos(a), cy + ry * sin(a))
}

# Resample a 2-column path to n evenly-spaced points by cumulative arc length
resample_stroke <- function(pts, n = 80) {
  d <- c(0, cumsum(sqrt(rowSums(diff(pts)^2))))
  s <- seq(0, d[length(d)], length.out = n)
  cbind(
    approx(d, pts[, 1], s, rule = 2)$y,
    approx(d, pts[, 2], s, rule = 2)$y
  )
}

# ── 2.  Letter stroke definitions  (height ≈ 1 unit) ─────────────────────────
#
# Each letter is a list of continuous stroke matrices (2 columns: x, y).
# Coordinate origin is bottom-left of each letter's bounding box.

ltrs <- list(
  f = list(
    # stem: vertical spine
    rbind(c(0.13, 0.00), c(0.13, 0.80)),
    # hook: arcs left→top→upper-right (clockwise, pi → pi/5)
    arc_pts(
      cx = 0.22,
      cy = 0.82,
      rx = 0.13,
      ry = 0.10,
      a_from = pi,
      a_to = pi / 5,
      n = 36
    ),
    # crossbar: horizontal bar at mid-height
    rbind(c(0.00, 0.52), c(0.38, 0.52))
  ),

  i = list(
    # stem
    rbind(c(0.10, 0.00), c(0.10, 0.60)),
    # dot: small circle above the stem (slightly open to avoid degenerate diff)
    arc_pts(
      cx = 0.10,
      cy = 0.75,
      rx = 0.06,
      ry = 0.06,
      a_from = 0,
      a_to = 2 * pi - 0.01,
      n = 32
    )
  ),

  b = list(
    # stem: full ascender
    rbind(c(0.08, 0.00), c(0.08, 0.90)),
    # bowl: D-arc from top (pi/2) clockwise to bottom (-pi/2)
    #   at pi/2  → (0.08, 0.55)  top, joins stem
    #   at 0     → (0.40, 0.275) widest right
    #   at -pi/2 → (0.08, 0.00)  bottom
    arc_pts(
      cx = 0.08,
      cy = 0.275,
      rx = 0.32,
      ry = 0.275,
      a_from = pi / 2,
      a_to = -pi / 2,
      n = 60
    )
  ),

  e = list(
    # body: counterclockwise arc, leaves mouth open on the right
    #   starts upper-right (pi/10), sweeps through top→left→bottom,
    #   ends lower-right (2pi - pi/10)
    arc_pts(
      cx = 0.25,
      cy = 0.30,
      rx = 0.25,
      ry = 0.30,
      a_from = pi / 10,
      a_to = 2 * pi - pi / 10,
      n = 72
    ),
    # midbar: horizontal crossbar reaching into the open mouth
    rbind(c(0.00, 0.30), c(0.46, 0.30))
  ),

  r = list(
    # stem
    rbind(c(0.07, 0.00), c(0.07, 0.55)),
    # shoulder: arch from stem top, sweeps up→right→trailing leg (clockwise)
    #   at pi    → (0.06, 0.55)  left, near stem top
    #   at pi/2  → (0.18, 0.65)  peak
    #   at 0     → (0.30, 0.55)  rightmost
    #   at -pi/4 → (0.26, 0.48)  trailing lower-right
    arc_pts(
      cx = 0.18,
      cy = 0.55,
      rx = 0.12,
      ry = 0.10,
      a_from = pi,
      a_to = -pi / 4,
      n = 44
    )
  )
)

# ── 3.  Letter placement ──────────────────────────────────────────────────────

ltr_w <- c(f = 0.45, i = 0.20, b = 0.50, e = 0.50, r = 0.42)
gap <- 0.18

# cumulative x-offset per letter: f=0.00, i=0.63, b=1.01, e=1.69, r=2.37
x_off <- c(0, cumsum(head(ltr_w, -1) + gap))
names(x_off) <- names(ltr_w)

# Shift each stroke by its letter's x-offset and collect into one flat list
all_strokes <- unlist(
  lapply(names(ltrs), function(nm) {
    lapply(ltrs[[nm]], function(s) {
      s[, 1] <- s[, 1] + x_off[nm]
      s
    })
  }),
  recursive = FALSE
)

# ── 4.  Orthographic camera (mild 3/4 view — keeps text readable) ─────────────

cam_az <- pi / 60 # ~3° azimuth  (nearly frontal — letters read horizontally)
cam_el <- pi / 9 # ~20° elevation (tilt toward viewer)

orth_proj <- function(M) {
  # Rotate around world-Z by azimuth
  x1 <- M[, 1] * cos(cam_az) + M[, 2] * sin(cam_az)
  y1 <- -M[, 1] * sin(cam_az) + M[, 2] * cos(cam_az)
  z1 <- M[, 3]
  # Tilt around screen-X by elevation
  sx <- x1
  sy <- y1 * cos(cam_el) - z1 * sin(cam_el) # screen y
  depth <- y1 * sin(cam_el) + z1 * cos(cam_el) # positive = toward camera
  cbind(sx, sy, depth)
}

# ── 5.  Fiber-bundle parameters ───────────────────────────────────────────────

n_pts <- 80 # points per stroke after resampling
n_sl <- 30 # streamlines per stroke
tube_r <- 0.050 # cross-section radius (data units)
z_amp <- 0.08 # Z-wave amplitude
z_freq <- 1.5 # wave cycles per stroke

# Golden-ratio (sunflower) disc — uniform, no clumping
phi_g <- (1 + sqrt(5)) / 2
k <- seq_len(n_sl)
theta_k <- 2 * pi * k / phi_g^2
rad_k <- sqrt(k / n_sl) * tube_r
u_off <- c(0, rad_k[-1] * cos(theta_k[-1])) # first fiber = base curve
v_off <- c(0, rad_k[-1] * sin(theta_k[-1]))

# ── 6.  Stroke processor ──────────────────────────────────────────────────────
#
# For each 2-D stroke:
#   1. Resample to n_pts evenly-spaced points
#   2. Lift to 3-D by adding a sinusoidal Z wave (creates depth undulation)
#   3. Compute Frenet-ish frame:
#        T = unit tangent via forward differences
#        N = T rotated 90° in XY plane  (stable on letter strokes)
#        B = T × N                      (≈ world-Z for 2-D strokes)
#   4. Offset n_sl fibers in the N–B plane (sunflower disc)
#   5. Project to screen; record DTI orientation colours

proc_stroke <- function(xy) {
  P2 <- resample_stroke(xy, n_pts)

  # Arc-length parameter s ∈ [0, 1]
  d_cum <- c(0, cumsum(sqrt(rowSums(diff(P2)^2))))
  s <- d_cum / d_cum[n_pts]

  # 3-D base curve: XY from letter, Z from sinusoidal wave
  P3 <- cbind(P2[, 1], P2[, 2], z_amp * sin(2 * pi * z_freq * s))

  # Tangent: forward difference everywhere, backward at last point
  dP <- rbind(
    diff(P3),
    P3[n_pts, , drop = FALSE] - P3[n_pts - 1L, , drop = FALSE]
  )
  T_ <- dP / pmax(sqrt(rowSums(dP^2)), 1e-10)

  # Normal: rotate T 90° in XY; divide by in-plane magnitude to normalize
  # (recycles length-n_pts vector across the matrix's 3 columns, dividing
  #  each row i by nN[i] — correct R broadcast behaviour for nrow(N_)==length(nN))
  nN <- pmax(sqrt(T_[, 1]^2 + T_[, 2]^2), 1e-10)
  N_ <- cbind(-T_[, 2], T_[, 1], 0) / nN

  # Binormal: T × N (already unit length for unit T, unit N ⊥ T; normalize for safety)
  B_ <- cbind(
    T_[, 2] * N_[, 3] - T_[, 3] * N_[, 2],
    T_[, 3] * N_[, 1] - T_[, 1] * N_[, 3],
    T_[, 1] * N_[, 2] - T_[, 2] * N_[, 1]
  )
  B_ <- B_ / pmax(sqrt(rowSums(B_^2)), 1e-10)

  # Generate fiber bundle
  do.call(
    rbind,
    lapply(seq_len(n_sl), function(i) {
      pts <- P3 + u_off[i] * N_ + v_off[i] * B_
      proj <- orth_proj(pts)
      n <- n_pts
      data.frame(
        x1 = proj[-n, 1],
        y1 = proj[-n, 2],
        x2 = proj[-1, 1],
        y2 = proj[-1, 2],
        d = (proj[-n, 3] + proj[-1, 3]) / 2, # mid-segment depth
        # DTI orientation colours: |T_x| → R, |T_y| → G, |T_z| → B
        r = abs(T_[-n, 1]),
        g = abs(T_[-n, 2]),
        b = abs(T_[-n, 3])
      )
    })
  )
}

# ── 7.  Process all strokes → combined segment data frame ────────────────────

segs_raw <- do.call(rbind, lapply(all_strokes, proc_stroke))

# Depth-sort: farthest first → closer ones render on top (correct occlusion)
segs_raw <- segs_raw[order(segs_raw$d), ]

# ── 7b. Ghost fiber arc ───────────────────────────────────────────────────────
#
# A faint DTI-coloured streamline bundle sweeping sinusoidally behind the
# lettering — gives depth context and fills the negative space inside the hex.
# Rendered as the bottom-most ggplot layer so letters always sit on top.

n_gh <- 250
t_gh <- seq(0, 1, length.out = n_gh)
gh_base <- cbind(
  X = 2.80 * t_gh, # spans full letter width
  Y = 1.20 + 0.15 * sin(2 * pi * t_gh), # arcs above the lettering
  Z = 0.30 * cos(3 * pi * t_gh) # depth undulation
)

# Frenet frame for the ghost path (same approach as proc_stroke)
dgh <- rbind(
  diff(gh_base),
  gh_base[n_gh, , drop = FALSE] - gh_base[n_gh - 1L, , drop = FALSE]
)
Tgh <- dgh / pmax(sqrt(rowSums(dgh^2)), 1e-10)
nNgh <- pmax(sqrt(Tgh[, 1]^2 + Tgh[, 2]^2), 1e-10)
Ngh <- cbind(-Tgh[, 2], Tgh[, 1], 0) / nNgh
Bgh <- cbind(
  Tgh[, 2] * Ngh[, 3] - Tgh[, 3] * Ngh[, 2],
  Tgh[, 3] * Ngh[, 1] - Tgh[, 1] * Ngh[, 3],
  Tgh[, 1] * Ngh[, 2] - Tgh[, 2] * Ngh[, 1]
)
Bgh <- Bgh / pmax(sqrt(rowSums(Bgh^2)), 1e-10)

# Sunflower-disc offsets — wider tube than the letters for a loose, airy look
n_gh_sl <- 8L
tube_r_gh <- 0.09
k_gh <- seq_len(n_gh_sl)
th_gh <- 2 * pi * k_gh / phi_g^2
rd_gh <- sqrt(k_gh / n_gh_sl) * tube_r_gh
u_gh <- c(0, rd_gh[-1] * cos(th_gh[-1]))
v_gh <- c(0, rd_gh[-1] * sin(th_gh[-1]))

ghost_segs <- do.call(
  rbind,
  lapply(seq_len(n_gh_sl), function(i) {
    pts <- gh_base + u_gh[i] * Ngh + v_gh[i] * Bgh
    proj <- orth_proj(pts)
    n <- n_gh
    data.frame(
      x1 = proj[-n, 1],
      y1 = proj[-n, 2],
      x2 = proj[-1, 1],
      y2 = proj[-1, 2],
      r = abs(Tgh[-n, 1]),
      g = abs(Tgh[-n, 2]),
      b = abs(Tgh[-n, 3])
    )
  })
)

# Pre-compute ghost colours: same DTI scheme but dimmed
c_ghost <- rgb(ghost_segs$r * 0.55, ghost_segs$g * 0.55, ghost_segs$b * 0.55)

# ── 8.  Tube shading: three-layer rendering ───────────────────────────────────
#
# Each segment drawn three times:
#   – wide dark "shadow"   → illusion of tube curvature
#   – medium coloured "body" → visible tube surface
#   – thin bright "highlight" → specular reflection
#
# Depth also modulates brightness: close = brighter, far = darker.

br <- scales::rescale(segs_raw$d, to = c(0.25, 1.0))

c_shadow <- rgb(
  segs_raw$r * br * 0.12,
  segs_raw$g * br * 0.12,
  segs_raw$b * br * 0.12
)

c_body <- rgb(
  pmin(segs_raw$r * br, 1),
  pmin(segs_raw$g * br, 1),
  pmin(segs_raw$b * br, 1)
)

c_hi <- rgb(
  pmin(segs_raw$r * br + 0.45, 1),
  pmin(segs_raw$g * br + 0.45, 1),
  pmin(segs_raw$b * br + 0.45, 1)
)

# ── 9.  ggplot panel ──────────────────────────────────────────────────────────

p <- ggplot(segs_raw) +
  # Ghost fiber arc — rendered first so it always sits behind the lettering
  geom_segment(
    data = ghost_segs,
    aes(x = x1, y = y1, xend = x2, yend = y2, color = I(c_ghost)),
    linewidth = 1.4,
    lineend = "round",
    alpha = 0.05
  ) +
  geom_segment(
    aes(x = x1, y = y1, xend = x2, yend = y2, color = I(c_shadow)),
    linewidth = 1.80,
    lineend = "round"
  ) +
  geom_segment(
    aes(x = x1, y = y1, xend = x2, yend = y2, color = I(c_body)),
    linewidth = 1.00,
    lineend = "round"
  ) +
  geom_segment(
    aes(x = x1, y = y1, xend = x2, yend = y2, color = I(c_hi)),
    linewidth = 0.30,
    lineend = "round"
  ) +
  coord_fixed() +
  theme_void() +
  theme_transparent()

# ── 10. Hex sticker ───────────────────────────────────────────────────────────
#
# The word "fiber" IS the artwork — suppress the hexSticker text label.
# s_width / s_height ratio (~1.85) matches the projected letter aspect ratio.

tmpfile <- tempfile(fileext = ".png")
sticker(
  p,
  package = "", # letters rendered as fiber art; no separate label
  p_size = 1,
  p_color = "#0d1117", # matches background → invisible
  s_x = 1.00,
  s_y = 1.00,
  s_width = 1.65,
  s_height = 0.89,
  h_fill = "#0d1117",
  h_color = "#f0f0f0",
  filename = tmpfile
)

usethis::use_logo(tmpfile)
unlink(tmpfile)
