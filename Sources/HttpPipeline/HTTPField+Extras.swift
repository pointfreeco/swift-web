import HTTPTypes

extension HTTPField.Name {
  public static var referrerPolicy: Self = .init("Referrer-Policy")!
  public static var xDownloadOptions: Self = .init("X-Download-Options")!
  public static var xFrameOptions: Self = .init("X-Frame-Options")!
  public static var xPermittedCrossDomainPolicies: Self = .init("X-Permitted-Cross-Domain-Policies")!
  public static var xXssProtection: Self = .init("X-XSS-Protection")!
}
