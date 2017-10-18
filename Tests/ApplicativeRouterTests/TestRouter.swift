import ApplicativeRouter
import Deriving
import Either
import Prelude

enum Routes {
  case root
  case pathComponents(param: Either<String, Int>, commentId: Int)
  case postBodyField(email: String)
  case postBodyJsonDecodable(episode: Episode, param: Int)
  case simpleQueryParams(ref: String?, active: Bool, t: Int)
}

let router: Router<Routes> = [

  // /home
  Routes.iso.root
    <¢> get %> lit("home") %> _end,

  // /home/episodes/:string_or_int/comments/:int
  Routes.iso.pathComponents
    <¢> get %> lit("home") %> lit("episodes") %> pathParam(.intOrString) <%> lit("comments") %> .int <% _end,

  // POST /signup
  Routes.iso.postBodyField
    <¢> post %> formField("email") <% lit("signup") <% _end,

  // POST /episodes/:id
  Routes.iso.postBodyJsonDecodable
    <¢> post %> jsonBody(Episode.self) <%> lit("episodes") %> .int <% _end,

  // /path/to/somewhere/cool?ref=:optional_string&active=:bool&t=:int
  Routes.iso.simpleQueryParams
    <¢> get %> lit("path") %> lit("to") %> lit("somewhere") %> lit("cool")
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

    case let (.postBodyField(lhs), .postBodyField(rhs)):
      return lhs == rhs

    case let (.postBodyJsonDecodable(lhs), .postBodyJsonDecodable(rhs)):
      return lhs == rhs

    case let (.simpleQueryParams(lhs0, lhs1, lhs2), .simpleQueryParams(rhs0, rhs1, rhs2)):
      return lhs0 == rhs0 && lhs1 == rhs1 && lhs2 == rhs2

    case (.root, _), (.pathComponents, _), (.postBodyField, _), (.postBodyJsonDecodable, _),
         (.simpleQueryParams, _):
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

    static let postBodyField = parenthesize <| PartialIso<String, Routes>(
      image: Routes.postBodyField,
      preimage: {
        guard case let .postBodyField(result) = $0 else { return nil }
        return result
    })

    static let postBodyJsonDecodable = parenthesize <| PartialIso<(Episode, Int), Routes>(
      image: Routes.postBodyJsonDecodable,
      preimage: {
        guard case let .postBodyJsonDecodable(result) = $0 else { return nil }
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

struct Episode: Codable, DerivingEquatable {
  let title: String
  let blurb: String
  let length: Int
  let category: String?
}
