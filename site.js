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
