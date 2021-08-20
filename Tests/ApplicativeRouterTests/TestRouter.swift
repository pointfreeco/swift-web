import ApplicativeRouter
import Either
import Prelude

struct SubscribeData: Codable {
  let plan: Int
  let quantity: Int
}

enum Routes {
  case home
  case root
  case pathComponents(param: Either<String, Int>, commentId: Int)
  case postBodyField(email: String)
  case postBodyFormData(SubscribeData)
  case postBodyJsonDecodable(episode: Episode, param: Int)
  case simpleQueryParams(ref: String?, active: Bool, t: Int)
  case codableQueryParams(SubscribeData)
  case redirect(String)
}

let router: Router<Routes> = [

  // /home
  Routes.iso.home
    <¢> get %> "home" %> end,

  // /
  Routes.iso.root
    <¢> get %> end,

  // /home/episodes/:string_or_int/comments/:int
  Routes.iso.pathComponents
    <¢> get %> "home" %> "episodes" %> pathParam(.intOrString) <%> "comments" %> .int <% end,

  // POST /signup
  Routes.iso.postBodyField
    <¢> post %> formField("email") <% "signup" <% end,

  // POST /subscribe
  Routes.iso.postBodyFormData
    <¢> post %> "subscribe" %> formBody(SubscribeData.self) <% end,

  // POST /episodes/:id
  Routes.iso.postBodyJsonDecodable
    <¢> post %> jsonBody(Episode.self) <%> "episodes" %> .int <% end,

  // /path/to/somewhere/cool?ref=:optional_string&active=:bool&t=:int
  Routes.iso.simpleQueryParams
    <¢> get %> "path" %> "to" %> "somewhere" %> "cool"
    %> queryParam("ref", opt(.string)) <%> queryParam("active", .bool) <%> queryParam("t", .int)
    <% end,

  // GET /subscribe?plan=:int
  Routes.iso.codableQueryParams
    <¢> get %> "subscribe" %> queryParams(SubscribeData.self)
    <% end,

  Routes.iso.redirect
    <¢> get %> "somewhere" %> queryParam("redirect", .string) <% end
  ]
  .reduce(.empty, <|>)

extension Routes: Equatable {
  static func ==(lhs: Routes, rhs: Routes) -> Bool {
    switch (lhs, rhs) {
    case (.home, .home), (.root, .root):
      return true

    case let (.pathComponents(lhs0, lhs1), .pathComponents(rhs0, rhs1)):
      return (lhs0, lhs1) == (rhs0, rhs1)

    case let (.postBodyField(lhs), .postBodyField(rhs)):
      return lhs == rhs

    case let (.postBodyFormData(lhs), .postBodyFormData(rhs)):
      return lhs.plan == rhs.plan

    case let (.postBodyJsonDecodable(lhs0, lhs1), .postBodyJsonDecodable(rhs0, rhs1)):
      return (lhs0, lhs1) == (rhs0, rhs1)

    case let (.simpleQueryParams(lhs0, lhs1, lhs2), .simpleQueryParams(rhs0, rhs1, rhs2)):
      return (lhs0, lhs1, lhs2) == (rhs0, rhs1, rhs2)

    case let (.codableQueryParams(lhs), .codableQueryParams(rhs)):
      return lhs.plan == rhs.plan

    case let (.redirect(lhs), .redirect(rhs)):
      return lhs == rhs

    default:
      return false
    }
  }
}

extension Routes {
  enum iso {
    static let home = parenthesize <| PartialIso(
      apply: const(.some(.home)),
      unapply: { $0 == .home ? () : nil }
    )

    static let root = parenthesize <| PartialIso(
      apply: const(.some(.root)),
      unapply: { $0 == .root ? () : nil }
    )

    static let pathComponents = parenthesize <| PartialIso(
      apply: Routes.pathComponents,
      unapply: {
        guard case let .pathComponents(a, b) = $0 else { return nil }
        return (a, b)
    })

    static let postBodyField = parenthesize <| PartialIso(
      apply: Routes.postBodyField,
      unapply: {
        guard case let .postBodyField(result) = $0 else { return nil }
        return result
    })

    static let postBodyFormData = parenthesize <| PartialIso(
      apply: Routes.postBodyFormData,
      unapply: {
        guard case let .postBodyFormData(result) = $0 else { return nil }
        return result
    })

    static let postBodyJsonDecodable = parenthesize <| PartialIso(
      apply: Routes.postBodyJsonDecodable,
      unapply: {
        guard case let .postBodyJsonDecodable(a, b) = $0 else { return nil }
        return (a, b)
    })

    static let simpleQueryParams = parenthesize <| PartialIso(
      apply: Routes.simpleQueryParams,
      unapply: {
        guard case let .simpleQueryParams(a, b, c) = $0 else { return nil }
        return (a, b, c)
    })

    static let codableQueryParams = parenthesize <| PartialIso(
      apply: Routes.codableQueryParams,
      unapply: {
        guard case let .codableQueryParams(result) = $0 else { return nil }
        return result
    })

    static let redirect = parenthesize <| PartialIso(
      apply: Routes.redirect,
      unapply: {
        guard case let .redirect(result) = $0 else { return nil }
        return result
    })
  }
}

struct Episode: Codable, Equatable {
  let title: String
  let blurb: String
  let length: Int
  let category: String?
}
