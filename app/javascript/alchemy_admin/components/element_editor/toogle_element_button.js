import { patch } from "alchemy_admin/utils/ajax"

export class ToggleElementButton extends HTMLElement {
  #collapsed = false

  constructor() {
    super()

    this.addEventListener("click", this)
  }

  handleEvent(event) {
    const elementEditor = event.target.closest("alchemy-element-editor")
    if (elementEditor === this.elementEditor) {
      this.toggle()
    }
  }

  /**
   * Expands or collapses element editor
   * If the element is dirty (has unsaved changes) it displays a confirm first.
   */
  async toggle() {
    if (this.collapsed) {
      await this.expand()
    } else {
      await this.collapse()
    }
  }

  /**
   * Collapses the element editor and persists the state on the server
   * @* @returns {Promise}
   */
  expand() {
    if (this.expanded && !this.compact) {
      return Promise.resolve("Element is already expanded.")
    }

    if (this.compact && this.parentElementEditor) {
      return this.parentElementEditor.expand()
    } else {
      const spinner = new Alchemy.Spinner("small")
      spinner.spin(this.toggleButton)
      this.toggleIcon?.classList.add("hidden")

      return new Promise((resolve, reject) => {
        post(Alchemy.routes.expand_admin_element_path(this.elementId))
          .then((response) => {
            const data = response.data

            // First expand all parent elements if necessary
            if (data.parentElementIds.length) {
              const selector = data.parentElementIds
                .map((id) => `#element_${id}`)
                .join(", ")
              document.querySelectorAll(selector).forEach((parentElement) => {
                parentElement.collapsed = false
                parentElement.toggleButton?.setAttribute("title", data.title)
              })
            }
            // Finally expand ourselve
            this.collapsed = false
            this.toggleButton?.setAttribute("title", data.title)
            // Resolve the promise that scrolls to the element very last
            resolve()
          })
          .catch((error) => {
            Alchemy.growl(error.message, "error")
            console.error(error)
            reject(error)
          })
          .finally(() => {
            this.toggleIcon?.classList?.remove("hidden")
            spinner.stop()
          })
      })
    }
  }

  /**
   * @returns {boolean}
   */
  get collapsed() {
    return this.#collapsed === true
  }

  get elementEditor() {
    return this.closest("alchemy-element-editor")
  }

  get icon() {
    return this.closest(".icon")
  }

  get elementId() {
    return this.elementEditor.elementId
  }
}

customElements.define("alchemy-toogle-element-button", ToggleElementButton)
