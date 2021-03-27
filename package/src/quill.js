import Quill from "quill"
import "quill/dist/quill.snow.css"

export default {
  init(container) {
    const quillOptions = {
      theme: "snow",
      modules: {
        toolbar: [
          ["bold", "italic", "underline"],
          [{ list: "bullet" }, { list: "ordered" }],
          [{ indent: "+1" }, { indent: "-1" }],
          ["clean"]
        ]
      },
      formats: [
        "align",
        "blockquote",
        "bold",
        "code-block",
        "direction",
        "header",
        "indent",
        "italic",
        "link",
        "list",
        "script",
        "strike",
        "underline"
      ]
    }

    container.querySelectorAll(".quill-editor").forEach((element) => {
      const editor = new Quill(element, quillOptions)
      editor.on("text-change", () => {
        console.log("Text change!", editor.getContents())
      })
    })
  }
}
