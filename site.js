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
