const HTML = document.querySelector("html")
const darkModeMQ = window.matchMedia("(prefers-color-scheme: dark)")

function on() {
  HTML.setAttribute("data-theme", "dark")
}

function off() {
  HTML.setAttribute("data-theme", "light")
}

function match(obj) {
  obj.matches ? on() : off()
}

match(darkModeMQ)
darkModeMQ.addEventListener("change", match.bind(this))

export default {
  toggle() {
    var theme = HTML.getAttribute("data-theme")
    theme === "dark" ? off() : on()
  }
}
