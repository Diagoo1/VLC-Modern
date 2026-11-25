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
  caption.className = "slider-caption";
  const title = document.createElement("div");
  const tools = document.createElement("div");
  tools.className = "slider-tools";
  const motion = matchMedia("(prefers-reduced-motion: reduce)");
  let current = 0;
  let playing = !motion.matches;
  let visible = !("IntersectionObserver" in window);
  let timer;

  function control(english, arabic, action) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "secondary";
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
    playButton.setAttribute("aria-pressed", String(playing));
    playButton.querySelector("[lang=en]").textContent = playing ? "Pause" : "Play";
    playButton.querySelector("[lang=ar]").textContent = playing ? "إيقاف مؤقت" : "تشغيل";
    if (playing && visible && !document.hidden) {
      timer = setTimeout(() => showScreenshot(current + 1), 5200);
    }
  }

  const playButton = control("Pause", "إيقاف مؤقت", () => {
    playing = !playing;
    updatePlayback();
  });
  tools.append(
    control("Previous", "السابق", () => showScreenshot(current - 1)),
    playButton,
    control("Next", "التالي", () => showScreenshot(current + 1))
  );
  fullSize.append(screenshot);
  caption.append(title, tools);
  figure.append(caption, fullSize);
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
    current = (index + shots.length) % shots.length;
    const shot = shots[current];
    const original = shot.querySelector("img");
    fullSize.href = shot.href;
    screenshot.src = original.src;
    screenshot.alt = original.alt;
    title.replaceChildren(...[...shot.querySelectorAll("span")].map(label => label.cloneNode(true)));
    buttons.forEach((button, position) => button.setAttribute("aria-pressed", String(position === current)));
    figure.getAnimations().forEach(animation => animation.cancel());
    if (!motion.matches) figure.animate(
      [{opacity: .6, transform: "translateY(5px)"}, {opacity: 1, transform: "translateY(0)"}],
      {duration: 300, easing: "ease-out"}
    );
    updatePlayback();
  }

  gallery.classList.add("is-interactive");
  gallery.replaceChildren(controls, figure);
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
