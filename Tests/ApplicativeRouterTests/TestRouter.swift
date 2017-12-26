import ApplicativeRouter
import Deriving
import Either
import Foundation
import Prelude

struct SubscribeData: Codable {
  let plan: Int
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
  case nested(Nested)

  enum Nested {
    case uuid(UUID)
  }
}

let router: Router<Routes> = [
  // /home
  Routes.iso.home
    <¢> get %> lit("home") %> end,

  // /
  Routes.iso.root
    <¢> get %> end,

  // /home/episodes/:string_or_int/comments/:int
  Routes.iso.pathComponents
    <¢> get %> lit("home") %> lit("episodes") %> pathParam(.intOrString) <%> lit("comments") %> .int <% end,

  // POST /signup
  Routes.iso.postBodyField
    <¢> post %> formField("email") <% lit("signup") <% end,

  // POST /subscribe
  Routes.iso.postBodyFormData
    <¢> post %> lit("subscribe") %> formBody(SubscribeData.self) <% end,

  // POST /episodes/:id
  Routes.iso.postBodyJsonDecodable
    <¢> post %> jsonBody(Episode.self) <%> lit("episodes") %> .int <% end,

  // /path/to/somewhere/cool?ref=:optional_string&active=:bool&t=:int
  Routes.iso.simpleQueryParams
    <¢> get %> lit("path") %> lit("to") %> lit("somewhere") %> lit("cool")
    %> queryParam("ref", opt(.string)) <%> queryParam("active", .bool) <%> queryParam("t", .int)
    <% end,

  // GET /subscribe?plan=:int
  Routes.iso.codableQueryParams
    <¢> get %> lit("subscribe") %> queryParams(SubscribeData.self)
    <% end,

  Routes.iso.redirect
    <¢> get %> lit("somewhere") %> queryParam("redirect", .string) <% end,

  Routes.iso.nested <<< Routes.Nested.iso.uuid
    <¢> get %> lit("uuid") %> pathParam(.uuid) <% end,
  ]
  .reduce(.empty, <|>)

extension Routes: Equatable {
  static func ==(lhs: Routes, rhs: Routes) -> Bool {
    switch (lhs, rhs) {
    case (.home, .home), (.root, .root):
      return true

    case let (.pathComponents(lhs0, lhs1), .pathComponents(rhs0, rhs1)):
      return lhs0 == rhs0 && lhs1 == rhs1

    case let (.postBodyField(lhs), .postBodyField(rhs)):
      return lhs == rhs

    case let (.postBodyFormData(lhs), .postBodyFormData(rhs)):
      return lhs.plan == rhs.plan

    case let (.postBodyJsonDecodable(lhs), .postBodyJsonDecodable(rhs)):
      return lhs == rhs

    case let (.simpleQueryParams(lhs0, lhs1, lhs2), .simpleQueryParams(rhs0, rhs1, rhs2)):
      return lhs0 == rhs0 && lhs1 == rhs1 && lhs2 == rhs2

    case let (.codableQueryParams(lhs), .codableQueryParams(rhs)):
      return lhs.plan == rhs.plan

    case let (.redirect(lhs), .redirect(rhs)):
      return lhs == rhs

    case let (.nested(lhs), .nested(rhs)):
      return lhs == rhs

    case (.home, _), (.root, _), (.pathComponents, _), (.postBodyField, _), (.postBodyJsonDecodable, _),
         (.simpleQueryParams, _), (.codableQueryParams, _), (.redirect, _), (.nested, _):
      return false
    }
  }
}

extension Routes.Nested: Equatable {
  static func ==(lhs: Routes.Nested, rhs: Routes.Nested) -> Bool {
    switch (lhs, rhs) {
    case let (.uuid(lhs), .uuid(rhs)):
      return lhs == rhs
    }
  }
}

extension Routes {
  enum iso {
    static let home = parenthesize <| PartialIso(
      apply: const(.some(.home)),
      unapply: { $0 == .home ? unit : nil }
    )

    static let root = parenthesize <| PartialIso(
      apply: const(.some(.root)),
      unapply: { $0 == .root ? unit : nil }
    )

    static let pathComponents = parenthesize <| PartialIso(
      apply: Routes.pathComponents,
      unapply: {
        guard case let .pathComponents(result) = $0 else { return nil }
        return result
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
        guard case let .postBodyJsonDecodable(result) = $0 else { return nil }
        return result
    })

    static let simpleQueryParams = parenthesize <| PartialIso(
      apply: Routes.simpleQueryParams,
      unapply: {
        guard case let .simpleQueryParams(result) = $0 else { return nil }
        return result
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

    static let nested = parenthesize <| PartialIso(
      apply: Routes.nested,
      unapply: {
        guard case let .nested(result) = $0 else { return nil }
        return result
    })
  }
}

extension Routes.Nested {
  enum iso {
    static let uuid = parenthesize <| PartialIso(
      apply: Routes.Nested.uuid,
      unapply: {
        guard case let .uuid(result) = $0 else { return nil }
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
