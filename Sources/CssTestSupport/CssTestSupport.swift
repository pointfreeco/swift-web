import Css
import SnapshotTesting

extension Strategy where A == Stylesheet, B == String {
  public static func css(_ config: Config) -> Strategy<Stylesheet, String> {
    var css = SimpleStrategy.lines.pullback { (stylesheet: Stylesheet) in
      render(config: config, css: stylesheet)
    }
    css.pathExtension = "css"
    return css
  }
}

extension Stylesheet: DefaultDiffable {
  public static let defaultStrategy: Strategy<Stylesheet, String> = .css(.pretty)
}
