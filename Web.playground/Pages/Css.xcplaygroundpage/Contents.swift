import Css
import Prelude

let css = body % (
  padding(all: .rem(2))
    <> background(Color.hsl(60, 0.5, 0.8))
)

print(render(css: css))
