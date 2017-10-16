import ApplicativeRouter
import Either
import Prelude

enum Routes {
  case root
  case pathComponents(episodeParam: Either<String, Int>, commentId: Int)
  case simpleQueryParams(ref: String?, active: Bool, t: Int)
}

let router: Router<Routes> = [

  Routes.iso.root
    <¢> lit("home") <% _end,

  // home/episodes/:string_or_int/comments/:int
  Routes.iso.pathComponents
    <¢> lit("home") %> lit("episodes") %> pathParam(Either.iso.int) <%> lit("comments") %> .int <% _end,

  // /path/to/somewhere/cool?ref=:optional_string&active=:bool&t=:int
  Routes.iso.simpleQueryParams
    <¢> lit("path") %> lit("to") %> lit("somewhere") %> lit("cool")
    %> "ref" <=> opt(.string) <%> "active" <=> .bool <%> "t" <=> .int
    <% _end

  ]
  .reduce(.empty, <|>)

extension Routes: Equatable {
  static func ==(lhs: Routes, rhs: Routes) -> Bool {
    switch (lhs, rhs) {
    case (.root, .root):
      return true

    case let (.pathComponents(lhs0, lhs1), .pathComponents(rhs0, rhs1)):
      return lhs0 == rhs0 && lhs1 == rhs1

    case let (.simpleQueryParams(lhs0, lhs1, lhs2), .simpleQueryParams(rhs0, rhs1, rhs2)):
      return lhs0 == rhs0 && lhs1 == rhs1 && lhs2 == rhs2

    case (.root, _), (.pathComponents, _), (.simpleQueryParams, _):
      return false
    }
  }
}

extension Routes {
  enum iso {
    static let root = parenthesize <| PartialIso<Prelude.Unit, Routes>(
      image: const(.some(.root)),
      preimage: {
        guard case .root = $0 else { return nil }
        return unit
    })

    static let pathComponents = parenthesize <| PartialIso<(Either<String, Int>, Int), Routes>(
      image: Routes.pathComponents,
      preimage: {
        guard case let .pathComponents(result) = $0 else { return nil }
        return result
    })

    static let simpleQueryParams = parenthesize <| PartialIso<(String?, Bool, Int), Routes>(
      image: Routes.simpleQueryParams,
      preimage: {
        guard case let .simpleQueryParams(result) = $0 else { return nil }
        return result
    })
  }
}
