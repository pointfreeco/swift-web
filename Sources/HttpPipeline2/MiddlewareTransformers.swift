import Prelude

public func requireHttps(allowedInsecureHosts: Set<String>)
  -> (@escaping AppMiddleware) -> AppMiddleware {

    return { middleware in
      return { conn in
        guard
          conn.request.scheme == "https",
          let host = conn.request.host,
          allowedInsecureHosts.contains(host)
          else { return conn |> middleware }

        return conn |> redirect(to: "https://" + host + conn.request.head.uri, status: .movedPermanently)
      }
    }
}
