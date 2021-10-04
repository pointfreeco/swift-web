import Cryptor
import Foundation

private let nonHexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF").inverted

func _decrypted(text encryptedText: String, secret: String) -> String? {
  // NB: Cryptor fatalErrros if secret isn't 32 characters long.
  guard secret.count == 32 else { return nil }
  // NB: Cryptor fatalErrors if secret contains non-hex digits.
  guard secret.rangeOfCharacter(from: nonHexCharacterSet) == nil else { return nil }
  // NB: Cryptor fatalErrors if `encryptedText` contains non-hex digits.
  guard encryptedText.rangeOfCharacter(from: nonHexCharacterSet) == nil else { return nil }
  // NB: Cryptor fatalErrros if `encryptedText` has an odd number of characters.
  guard encryptedText.count % 2 == 0 else { return nil }

  let secretBytes = CryptoUtils.byteArray(fromHex: secret)
  let iv = [UInt8](repeating: 0, count: secretBytes.count)
  let encryptedTextBytes = CryptoUtils.byteArray(fromHex: encryptedText)

  let decryptedText = (try? Cryptor(operation: .decrypt, algorithm: .aes, options: .none, key: secretBytes, iv: iv))?
    .update(byteArray: encryptedTextBytes)?
    .final()

  return decryptedText
    .map { Data($0.filter { $0 != 0 }) }
    .flatMap { String.init(data: $0, encoding: .utf8) }
}
