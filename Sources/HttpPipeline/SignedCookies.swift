import Crypto
import Foundation

extension Response.Header {
  /// Computes a signed cookie.
  ///
  /// - Parameters:
  ///   - key: The name of the cookie.
  ///   - value: The data of the cookie to sign.
  ///   - options: (Optional) Extra options to attach to the cookie.
  ///   - secret: The secret to sign the cookie with. This value must also be provided to verify a signature.
  ///   - encrypt: (Optional) Further encrypts the signed cookie using the secret provided.
  /// - Returns: A `Set-Cookie` header containing the signed cookie.
  public static func setSignedCookie(
    key: String,
    data: Data,
    options: Set<CookieOption> = [],
    secret: String,
    encrypt: Bool = false,
    nonce: [UInt8]? = nil
    )
    -> Response.Header? {

      let encodedValue = data.base64EncodedString()
      guard let computedDigest = digest(value: encodedValue, secret: secret) else { return nil }

      let signedValue = encodedValue + "--" + computedDigest
      guard let finalValue = encrypt ? encrypted(text: signedValue, secret: secret, nonce: nonce) : signedValue
        else { return nil }

      return .some(.setCookie(key, finalValue, options.union([.httpOnly])))
  }

  /// A helper for creating a signed cookie of a string value.
  /// Calls `setSignedCookie(key:data:options:secret)`.
  public static func setSignedCookie(
    key: String,
    value: String,
    options: Set<CookieOption> = [],
    secret: String,
    encrypt: Bool = false,
    nonce: [UInt8]? = nil
    )
    -> Response.Header? {

      return setSignedCookie(
        key: key, data: Data(value.utf8), options: options, secret: secret, encrypt: encrypt, nonce: nonce
      )
  }

  /// A helper for creating a signed cookie of an encodable value.
  /// Calls `setSignedCookie(key:data:options:secret)`.
  public static func setSignedCookie<A: Encodable>(
    key: String,
    value: A,
    options: Set<CookieOption> = [],
    secret: String,
    encrypt: Bool = false,
    nonce: [UInt8]? = nil
    )
    -> Response.Header? {

      return (try? JSONEncoder().encode(value))
        .flatMap { setSignedCookie(key: key, data: $0, options: options, secret: secret, encrypt: encrypt, nonce: nonce) }
  }

  /// Verifies signed cookie data using the secret that it was signed with.
  ///
  /// - Parameters:
  ///   - signedCookieValue: The cookie value that was stored in the signed cookie. It should be of the form
  ///                        "\(data)--\(digest)".
  ///   - secret: The secret used to sign the cookie.
  /// - Returns: The data of the cookie value if the verification was successful, and `nil` otherwise.
  public static func verifiedData(signedCookieValue: String, secret: String) -> Data? {
    // We can determine if we need to decrypt by checking if the cookie contains the `--` delimeter.
    let decrypt = !signedCookieValue.contains("--")

    guard let cookieValue = decrypt ? decrypted(text: signedCookieValue, secret: secret) : signedCookieValue
      else { return nil }

    let parts = cookieValue.components(separatedBy: "--")
    guard let encodedValue = parts.first,
      let providedDigest = parts.last,
      parts.count == 2
      else {
        return nil
    }

    let trueDigest = digest(value: encodedValue, secret: secret)

    guard trueDigest == providedDigest else { return nil }
    guard let value = base64DecodedData(string: encodedValue) else { return nil }

    return .some(value)
  }

  /// Helper function that calls `verifiedData` and then tries converting the data to a string.
  public static func verifiedString(signedCookieValue: String, secret: String)
    -> String? {
      return verifiedData(signedCookieValue: signedCookieValue, secret: secret)
        .map { String(decoding: $0, as: UTF8.self) }
  }

  /// Helper function that calls `verifiedData` and then tries to decode the data into an `A`.
  public static func verifiedValue<A: Decodable>(signedCookieValue: String, secret: String) -> A? {
      return verifiedData(signedCookieValue: signedCookieValue, secret: secret)
        .flatMap { try? JSONDecoder().decode(A.self, from: $0) }
  }
}

public func digest(value: String, secret: String) -> String? {
  let keyBytes = [UInt8](hex: secret)
  let valueBytes = [UInt8](value.utf8)
  let key = SymmetricKey(data: keyBytes)
  let digestBytes = Crypto.HMAC<SHA256>.authenticationCode(for: valueBytes, using: key)
  guard
    Crypto.HMAC<SHA256>
      .isValidAuthenticationCode(digestBytes, authenticating: valueBytes, using: key)
  else { return nil }
  return Data(digestBytes).base64EncodedString()
}

public func hexDigest(value: String, asciiSecret: String) -> String? {
  let keyBytes = [UInt8](asciiSecret.utf8)
  let valueBytes = [UInt8](value.utf8)
  let key = SymmetricKey(data: keyBytes)
  let digestBytes = Crypto.HMAC<SHA256>.authenticationCode(for: valueBytes, using: key)
  guard
    Crypto.HMAC<SHA256>
      .isValidAuthenticationCode(digestBytes, authenticating: valueBytes, using: key)
  else { return nil }
  return digestBytes.map { String(format: "%02x", $0) }.joined()
}

public func encrypted(text plainText: String, secret: String, nonce nonceBytes: [UInt8]? = nil) -> String? {
  do {
    let secretBytes = [UInt8](hex: secret)
    let key = SymmetricKey(data: secretBytes)
    let plainTextBytes = [UInt8](plainText.utf8)
    let nonce = try nonceBytes.map { try AES.GCM.Nonce(data: $0) }
    let box = try AES.GCM.seal(plainTextBytes, using: key, nonce: nonce)
    guard let data = box.combined
    else { return nil }
    return data.map { String(format: "%02x", $0) }.joined()
  } catch {
    return nil
  }
}

public func decrypted(text encryptedText: String, secret: String) -> String? {
  do {
    let secretBytes = [UInt8](hex: secret)
    let key = SymmetricKey(data: secretBytes)
    let encryptedBytes = [UInt8](hex: encryptedText)
    let box = try AES.GCM.SealedBox(combined: encryptedBytes)
    let data = try AES.GCM.open(box, using: key)
    return String(decoding: data, as: UTF8.self)
  } catch {
    return _decrypted(text: encryptedText, secret: secret)
  }
}

private func base64DecodedData(string: String) -> Data? {
  return Data(base64Encoded: Data(string.utf8))
}

extension Array where Element == UInt8 {
  public init(hex: String) {
    self.init()
    self.reserveCapacity(hex.unicodeScalars.lazy.underestimatedCount)
    var buffer: UInt8?
    var skip = hex.hasPrefix("0x") ? 2 : 0
    for char in hex.unicodeScalars.lazy {
      guard skip == 0 else {
        skip -= 1
        continue
      }
      guard char.value >= 48 && char.value <= 102 else {
        removeAll()
        return
      }
      let v: UInt8
      let c: UInt8 = UInt8(char.value)
      switch c {
        case let c where c <= 57:
          v = c - 48
        case let c where c >= 65 && c <= 70:
          v = c - 55
        case let c where c >= 97:
          v = c - 87
        default:
          removeAll()
          return
      }
      if let b = buffer {
        append(b << 4 | v)
        buffer = nil
      } else {
        buffer = v
      }
    }
    if let b = buffer {
      append(b)
    }
  }
}
