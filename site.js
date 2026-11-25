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
