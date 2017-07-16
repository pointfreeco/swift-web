import Css
import DoctorPretty

private func prettyPrint(stylesheet: Stylesheet) -> Doc {
  return stylesheet.rules.map(prettyPrint(rule:)).vcat()
}

private func prettyPrint(rule: Rule) -> Doc {
  fatalError()
}
