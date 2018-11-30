import Css
import SnapshotTesting

extension Snapshotting where Value == Stylesheet, Format == String {
  public static let css = Snapshotting.css()

  public static func css(_ config: Config = .pretty) -> Snapshotting<Stylesheet, String> {
    var css = SimplySnapshotting.lines.pullback { (stylesheet: Stylesheet) in
      render(config: config, css: stylesheet)
    }
    css.pathExtension = "css"
    return css
  }
}
