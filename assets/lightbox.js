// =============================================================================
// lightbox.js -- click a gallery thumbnail (a.lightbox-link) to view it large.
// Close: click outside the image, the x button, or Esc.
// Browse: the < > buttons or the left/right arrow keys.
// =============================================================================
document.addEventListener("DOMContentLoaded", function () {
  var links = Array.prototype.slice.call(document.querySelectorAll("a.lightbox-link"));
  if (!links.length) return;                       // page has no gallery

  // ---- Build the overlay once ------------------------------------------------
  var box = document.createElement("div");
  box.className = "lightbox";
  box.innerHTML =
    '<button class="lb-close" aria-label="Close">&times;</button>' +
    '<button class="lb-prev" aria-label="Previous">&#8249;</button>' +
    '<img alt="">' +
    '<button class="lb-next" aria-label="Next">&#8250;</button>';
  document.body.appendChild(box);
  if (links.length < 2) box.classList.add("single"); // hide arrows for 1 image

  var img = box.querySelector("img");
  var current = 0;

  // ---- Open / close / browse ---------------------------------------------------
  function show(i) {
    current = (i + links.length) % links.length;   // wrap around at both ends
    img.src = links[current].href;
    img.alt = links[current].querySelector("img").alt;
    box.classList.add("open");
  }
  function close() { box.classList.remove("open"); }

  links.forEach(function (a, i) {
    a.addEventListener("click", function (e) { e.preventDefault(); show(i); });
  });
  box.querySelector(".lb-close").addEventListener("click", close);
  box.querySelector(".lb-prev").addEventListener("click", function (e) { e.stopPropagation(); show(current - 1); });
  box.querySelector(".lb-next").addEventListener("click", function (e) { e.stopPropagation(); show(current + 1); });
  box.addEventListener("click", function (e) { if (e.target === box) close(); });
  document.addEventListener("keydown", function (e) {
    if (!box.classList.contains("open")) return;
    if (e.key === "Escape") close();
    if (e.key === "ArrowLeft") show(current - 1);
    if (e.key === "ArrowRight") show(current + 1);
  });
});