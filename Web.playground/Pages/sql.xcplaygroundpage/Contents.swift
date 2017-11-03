import Prelude
import Optics

protocol PGtype {}
protocol PGnum: PGtype {}
enum PGbool: PGtype {}
enum PGnumeric: PGnum {}

struct Definition {
  let rendered: String
}

struct Query {
  let rendered: String
}

typealias Condition = Expression<PGbool>

let `true` = Condition(rendered: "true")
let `false` = Condition(rendered: "false")

struct TableExpression {
  var fromClause: FromClause
  var whereClause: [Condition]
  var limitClause: [Int] // todo: maybe unsigned?
  var offsetClause: [Int]
}

struct Manipulation: ExpressibleByStringLiteral {
  let rendered: String
  public init(stringLiteral value: String) {
    self.rendered = value
  }
}

struct Table: ExpressibleByStringLiteral {
  let rendered: String
  public init(stringLiteral value: String) {
    self.rendered = value
  }
}

struct Expression<A> {
  let rendered: String
}

func + <A: PGnum> (lhs: Expression<A>, rhs: Expression<A>) -> Expression<A> {
  return .init(rendered: lhs.rendered + " + " + rhs.rendered)
}

func - <A: PGnum> (lhs: Expression<A>, rhs: Expression<A>) -> Expression<A> {
  return .init(rendered: lhs.rendered + " - " + rhs.rendered)
}

func * <A: PGnum> (lhs: Expression<A>, rhs: Expression<A>) -> Expression<A> {
  return .init(rendered: lhs.rendered + " * " + rhs.rendered)
}

func && (lhs: Condition, rhs: Condition) -> Condition {
  return .init(rendered: lhs.rendered + " AND " + rhs.rendered)
}

func || (lhs: Condition, rhs: Condition) -> Condition {
  return .init(rendered: lhs.rendered + " OR " + rhs.rendered)
}

func < <A> (lhs: Expression<A>, rhs: Expression<A>) -> Condition {
  return .init(rendered: lhs.rendered + " < " + rhs.rendered)
}

indirect enum FromClause {
  case table(Table, as: String)
  case subquery(alias: String, Query)
  case crossJoin(right: FromClause, left: FromClause)
  case innerJoin(right: FromClause, on: Expression<PGbool>, left: FromClause)
}

func crossJoin(right: FromClause) -> (FromClause) -> FromClause {
  return { .crossJoin(right: right, left: $0) }
}
func innerJoin(_ right: FromClause, on: Expression<PGbool>) -> (FromClause) -> FromClause {
  return { left in .innerJoin(right: right, on: on, left: left) }
}

func render(_ fromClause: FromClause) -> String {
  switch fromClause {
  case let .table(table, alias):
    return "\(table.rendered) AS \(alias)"
  case let .subquery(alias, query):
    return "\(query.rendered) AS \(alias)"
  case let .crossJoin(right, left):
    return "\(render(left)) CROSS JOIN \(render(right))"
  case let .innerJoin(right, on, left):
    return "\(render(left)) INNER JOIN \(render(right)) ON \(on.rendered)"
  default:
    fatalError()
  }
}

func `where`(_ condition: Condition) -> (TableExpression) -> TableExpression {
  return { exp in
    exp |> \.whereClause %~ { $0 + [condition] }
  }
}

func limit(_ n: Int) -> (TableExpression) -> TableExpression {
  return { exp in
    exp |> \.limitClause %~ { $0 + [n] }
  }
}
func offset(_ n: Int) -> (TableExpression) -> TableExpression {
  return { exp in
    exp |> \.offsetClause %~ { $0 + [n] }
  }
}

func render(_ expression: TableExpression) -> String {
  let renderedFrom = "FROM \(render(expression.fromClause))"

  let renderedWhere: String
  if expression.whereClause.count == 0 {
    renderedWhere = ""
  } else {
    renderedWhere = "WHERE \(expression.whereClause.reduce(`true`, &&).rendered)"
  }

  let renderedLimit = expression.limitClause.min().map { "LIMIT \($0)" } ?? ""

  let renderedOffset: String
  if expression.offsetClause.count == 0 {
    renderedOffset =  ""
  } else {
    renderedOffset = "OFFSET \(expression.offsetClause.reduce(0, +))"
  }

  return [
    renderedFrom,
    renderedWhere,
    renderedLimit,
    renderedOffset
  ]
  .joined(separator: "\n")
}

func from(_ fromClause: FromClause) -> TableExpression {
  return TableExpression(
    fromClause: fromClause,
    whereClause: [],
    limitClause: [],
    offsetClause: []
  )
}

//TableExpression(
//  fromClause
//)

func select<A: PGtype>(_ columns: [Expression<A>], _ exp: TableExpression) -> Query {
  let renderedColumns = columns.map { $0.rendered }.joined(separator: ", ")

  return Query(
    rendered: "SELECT \(renderedColumns) \(render(exp))"
  )
}

print(
  select(
    [`true`, `false`],
    from(
      .table("users", as: "u")
        |> innerJoin(.table("episodes", as: "e"), on: `true`)
      )
      |> `where`(`true` && `false`)
      |> limit(10)
      |> limit(20)
      |> offset(2)
      |> offset(4)
    )
    .rendered
)

print("✅")
