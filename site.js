const languageMenu = document.querySelector(".language-menu");
const languageButtons = [...document.querySelectorAll("[data-language]")];
function setLanguage(value) {
  const chosen = value === "ar" ? "ar" : "en";
  document.documentElement.lang = chosen;
  document.documentElement.dir = chosen === "ar" ? "rtl" : "ltr";
  languageButtons.forEach(button => button.setAttribute("aria-pressed", String(button.dataset.language === chosen)));
}
let preferred = new URLSearchParams(location.search).get("lang");
try { preferred ||= localStorage.getItem("vlc-modern-language"); } catch {}
setLanguage(preferred || (navigator.language.startsWith("ar") ? "ar" : "en"));
for (const button of languageButtons) {
  button.addEventListener("click", () => {
    setLanguage(button.dataset.language);
    languageMenu.open = false;
    languageMenu.querySelector("summary").focus();
    const url = new URL(location.href);
    if (url.searchParams.has("lang")) {
      url.searchParams.set("lang", button.dataset.language);
      history.replaceState(null, "", url);
    }
    try { localStorage.setItem("vlc-modern-language", button.dataset.language); } catch {}
  });
}

document.addEventListener("click", event => {
  if (languageMenu.open && !languageMenu.contains(event.target)) languageMenu.open = false;
});
languageMenu.addEventListener("keydown", event => {
  if (event.key === "Escape" && languageMenu.open) {
    languageMenu.open = false;
    languageMenu.querySelector("summary").focus();
  }
});

const topLink = document.querySelector(".to-top");
function updateTopLink() {
  topLink.hidden = window.scrollY < 320;
}
window.addEventListener("scroll", updateTopLink, {passive: true});
updateTopLink();

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
  caption.className = "slider-caption";
  const title = document.createElement("div");
  title.className = "image-tag";
  const tools = document.createElement("div");
  tools.className = "slider-tools";
  const dialog = document.createElement("dialog");
  dialog.className = "image-viewer";
  dialog.setAttribute("aria-label", "Screenshot slideshow / عرض الصور");
  const viewerImage = document.createElement("img");
  const viewerTitle = document.createElement("div");
  viewerTitle.className = "viewer-title image-tag";
  const viewerTools = document.createElement("div");
  viewerTools.className = "slider-tools";
  const motion = matchMedia("(prefers-reduced-motion: reduce)");
  let current = 0;
  let playing = !motion.matches;
  let visible = !("IntersectionObserver" in window);
  let timer;

  function control(icon, english, arabic, action) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "secondary icon-control";
    button.dataset.icon = icon;
    for (const [lang, text] of [["en", english], ["ar", arabic]]) {
      const label = document.createElement("span");
      label.lang = lang;
      label.textContent = text;
      button.append(label);
    }
    button.addEventListener("click", action);
    return button;
  }

  function updatePlayback() {
    clearTimeout(timer);
    for (const button of [playButton, viewerPlay]) {
      button.setAttribute("aria-pressed", String(playing));
      button.dataset.icon = playing ? "pause" : "play";
      button.querySelector("[lang=en]").textContent = playing ? "Pause" : "Play";
      button.querySelector("[lang=ar]").textContent = playing ? "إيقاف مؤقت" : "تشغيل";
    }
    if (playing && (visible || dialog.open) && !document.hidden) {
      timer = setTimeout(() => showScreenshot(current + 1), 5200);
    }
  }

  const playButton = control("pause", "Pause", "إيقاف مؤقت", () => {
    playing = !playing;
    updatePlayback();
  });
  tools.append(
    control("previous", "Previous", "السابق", () => showScreenshot(current - 1)),
    playButton,
    control("next", "Next", "التالي", () => showScreenshot(current + 1))
  );
  const viewerPlay = control("play", "Play", "تشغيل", () => {
    playing = !playing;
    updatePlayback();
  });
  const closeViewer = control("close", "Close", "إغلاق", () => dialog.close());
  viewerTools.append(
    control("previous", "Previous", "السابق", () => showScreenshot(current - 1)),
    viewerPlay,
    control("next", "Next", "التالي", () => showScreenshot(current + 1)),
    closeViewer
  );
  dialog.append(viewerTitle, viewerImage, viewerTools);
  document.body.append(dialog);
  fullSize.addEventListener("click", (event) => {
    if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
    event.preventDefault();
    dialog.showModal();
    closeViewer.focus();
    updatePlayback();
  });
  dialog.addEventListener("click", event => {
    if (event.target === dialog) {
      const bounds = dialog.getBoundingClientRect();
      if (event.clientX < bounds.left || event.clientX > bounds.right ||
          event.clientY < bounds.top || event.clientY > bounds.bottom) dialog.close();
    }
  });
  dialog.addEventListener("close", () => {
    fullSize.focus({preventScroll: true});
    updatePlayback();
  });
  dialog.addEventListener("keydown", event => {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
    const forward = event.key === (document.documentElement.dir === "rtl" ? "ArrowLeft" : "ArrowRight");
    event.preventDefault();
    showScreenshot(current + (forward ? 1 : -1));
  });
  fullSize.append(screenshot);
  caption.append(title, tools, controls);
  figure.append(fullSize, caption);
  const buttons = shots.map((shot, index) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "slide-dot";
    for (const label of shot.querySelectorAll("span")) button.append(label.cloneNode(true));
    button.addEventListener("click", () => showScreenshot(index));
    controls.append(button);
    return button;
  });

  function showScreenshot(index) {
    current = (index + shots.length) % shots.length;
    const shot = shots[current];
    const original = shot.querySelector("img");
    fullSize.href = shot.href;
    screenshot.src = original.src;
    screenshot.alt = original.alt;
    title.replaceChildren(...[...shot.querySelectorAll("span")].map(label => label.cloneNode(true)));
    viewerImage.src = original.src;
    viewerImage.alt = original.alt;
    viewerTitle.replaceChildren(...[...shot.querySelectorAll("span")].map(label => label.cloneNode(true)));
    buttons.forEach((button, position) => button.setAttribute("aria-pressed", String(position === current)));
    figure.getAnimations().forEach(animation => animation.cancel());
    if (!motion.matches) figure.animate(
      [{opacity: .6, transform: "translateY(5px)"}, {opacity: 1, transform: "translateY(0)"}],
      {duration: 300, easing: "ease-out"}
    );
    updatePlayback();
  }

  gallery.classList.add("is-interactive");
  gallery.replaceChildren(figure);
  if ("IntersectionObserver" in window) {
    new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting;
      updatePlayback();
    }, {threshold: .2}).observe(gallery);
  }
  document.addEventListener("visibilitychange", updatePlayback);
  motion.addEventListener("change", () => {
    if (motion.matches) playing = false;
    updatePlayback();
  });
  function enableSwipe(surface) {
    let start = null;
    let suppressClick = false;
    surface.classList.add("swipe-image");
    surface.addEventListener("dragstart", event => event.preventDefault());
    surface.addEventListener("pointerdown", event => {
      if (!event.isPrimary || event.button !== 0) return;
      suppressClick = false;
      start = {id: event.pointerId, x: event.clientX, y: event.clientY};
      surface.setPointerCapture(event.pointerId);
    });
    surface.addEventListener("pointerup", event => {
      if (start?.id !== event.pointerId) return;
      const dx = event.clientX - start.x;
      const dy = event.clientY - start.y;
      start = null;
      if (Math.abs(dx) < 42 || Math.abs(dx) <= Math.abs(dy) * 1.2) return;
      suppressClick = true;
      const direction = document.documentElement.dir === "rtl" ? -1 : 1;
      showScreenshot(current + (dx < 0 ? direction : -direction));
    });
    for (const type of ["pointercancel", "lostpointercapture"]) {
      surface.addEventListener(type, event => {
        if (start?.id === event.pointerId) start = null;
      });
    }
    surface.addEventListener("click", event => {
      if (!suppressClick || event.detail === 0) return;
      suppressClick = false;
      event.preventDefault();
      event.stopImmediatePropagation();
    }, true);
  }

  enableSwipe(fullSize);
  enableSwipe(viewerImage);
  showScreenshot(0);
}
const navLinks = [...document.querySelectorAll(".header nav a")];
const navSections = navLinks.map(link => document.querySelector(link.hash));

function updateCurrentSection() {
  let active = -1;
  for (const [index, section] of navSections.entries()) {
    if (!section) continue;
    const offset = parseFloat(getComputedStyle(section).scrollMarginTop) || 0;
    if (section.getBoundingClientRect().top <= offset + 2) active = index;
  }
  const page = document.documentElement;
  if (window.scrollY > 0 && window.scrollY + window.innerHeight >= page.scrollHeight - 2) {
    active = navSections.length - 1;
  }
  navLinks.forEach((link, index) => {
    if (index === active) link.setAttribute("aria-current", "location");
    else link.removeAttribute("aria-current");
  });
}

let sectionFrame = 0;
function scheduleSectionUpdate() {
  if (sectionFrame) return;
  sectionFrame = requestAnimationFrame(() => {
    sectionFrame = 0;
    updateCurrentSection();
  });
}

window.addEventListener("scroll", scheduleSectionUpdate, {passive: true});
window.addEventListener("resize", scheduleSectionUpdate);
window.addEventListener("hashchange", scheduleSectionUpdate);
window.addEventListener("load", scheduleSectionUpdate);
scheduleSectionUpdate();
