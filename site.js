const language = document.querySelector("#language");
function setLanguage(value) {
  const arabic = value === "ar";
  document.documentElement.lang = arabic ? "ar" : "en";
  document.documentElement.dir = arabic ? "rtl" : "ltr";
  language.textContent = arabic ? "English" : "العربية";
  language.setAttribute("aria-label", arabic ? "Switch to English" : "التبديل إلى العربية");
}
let preferred = new URLSearchParams(location.search).get("lang");
try { preferred ||= localStorage.getItem("vlc-modern-language"); } catch {}
setLanguage(preferred || (navigator.language.startsWith("ar") ? "ar" : "en"));
language.addEventListener("click", () => {
  const next = document.documentElement.lang === "ar" ? "en" : "ar";
  setLanguage(next);
  try { localStorage.setItem("vlc-modern-language", next); } catch {}
});

if ("IntersectionObserver" in window && !matchMedia("(prefers-reduced-motion: reduce)").matches) {
  const observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) {
        entry.target.classList.add("in-view");
        observer.unobserve(entry.target);
      }
    }
  }, { threshold: 0.1 });
  document.querySelectorAll(".reveal").forEach((section) => observer.observe(section));
}

const gallery = document.querySelector(".gallery");
const shots = [...gallery.querySelectorAll("a")];
if (shots.length) {
  const controls = document.createElement("div");
  controls.className = "gallery-controls";
  const figure = document.createElement("figure");
  figure.className = "gallery-preview";
  const fullSize = document.createElement("a");
  const screenshot = document.createElement("img");
  const caption = document.createElement("figcaption");
  fullSize.append(screenshot);
  figure.append(fullSize, caption);
  const buttons = shots.map((shot, index) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "secondary";
    for (const label of shot.querySelectorAll("span")) button.append(label.cloneNode(true));
    button.addEventListener("click", () => showScreenshot(index));
    controls.append(button);
    return button;
  });
  function showScreenshot(index) {
    const shot = shots[index];
    const original = shot.querySelector("img");
    fullSize.href = shot.href;
    screenshot.src = original.src;
    screenshot.alt = original.alt;
    caption.replaceChildren(...[...shot.querySelectorAll("span")].map(label => label.cloneNode(true)));
    buttons.forEach((button, current) => button.setAttribute("aria-pressed", String(current === index)));
    figure.classList.remove("changed");
    requestAnimationFrame(() => figure.classList.add("changed"));
  }
  gallery.classList.add("is-interactive");
  gallery.replaceChildren(controls, figure);
  showScreenshot(0);
}
const navLinks = [...document.querySelectorAll(".header nav a")];
if ("IntersectionObserver" in window) {
  const sections = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      for (const link of navLinks) {
        if (link.hash === "#" + entry.target.id) link.setAttribute("aria-current", "location");
        else link.removeAttribute("aria-current");
      }
    }
  }, { rootMargin: "-25% 0px -55%" });
  for (const link of navLinks) {
    const target = document.querySelector(link.hash);
    if (target) sections.observe(target);
  }
}
