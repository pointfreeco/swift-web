import ApplicativeRouter
import Css
import Html
import HttpPipeline
import HtmlPrettyPrint
import PlaygroundSupport
import Cocoa

let document = html(
  [
    head(
      [
        title("Few, but ripe..."),
        meta([name("author"), content("Brandon Williams")]),
        meta([name("description"), content("Articles about math, functional programming and Swift.")]),
        meta([rel("stylesheet"), href("main.css")])
      ]
    ),
    body(
      [ id("article"),
        `class`("article-body"),
        style("background: white;color: #eee;") ],
      [
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean dictum lorem at elit finibus, vitae condimentum justo."
        ]
    )
  ]
)

func render(pageWidth: Int) {
  textView.string = prettyPrint(node: document, pageWidth: pageWidth)
}

class DraggableView: NSView {
  var lastPageWidth = 0
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
  }

  override func mouseDown(with event: NSEvent) {

  }

  override func mouseDragged(with event: NSEvent) {
    let location = self.superview?.convert(event.locationInWindow, to: nil)
    self.frame.origin.x = location!.x

    let newPageWidth = Int(self.frame.origin.x / charWidth)
    if self.lastPageWidth == newPageWidth {
      return
    }
    self.lastPageWidth = newPageWidth

    render(pageWidth: newPageWidth)
  }
}

let maxCharPerLine: CGFloat = 95
let canvasSize = NSSize(width: 700, height: 400)
let charWidth: CGFloat = canvasSize.width / maxCharPerLine
let maxPageWidth = Int(canvasSize.width / charWidth)
let fontSize: CGFloat = 12

let draggableLine = DraggableView(frame: .init(x: canvasSize.width - charWidth, y: 0, width: charWidth, height: canvasSize.height))
draggableLine.wantsLayer = true
draggableLine.layer?.backgroundColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)

let container = NSView(frame: .init(origin: .zero, size: canvasSize))
container.wantsLayer = true
container.layer?.backgroundColor = CGColor.white

let textView = NSTextView(frame: .init(origin: .zero, size: canvasSize))
textView.font = NSFont.init(name: "Menlo", size: fontSize)


container.addSubview(textView)
container.addSubview(draggableLine)

render(pageWidth: maxPageWidth)

PlaygroundPage.current.liveView = container



