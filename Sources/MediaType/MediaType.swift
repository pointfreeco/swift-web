public enum MediaType: CustomStringConvertible {
  case application(Application)
  case audio(Audio)
  case font(Font)
  case example(String)
  case image(Image)
  case message(String)
  case model(String)
  case multipart(Multipart, boundary: String?)
  case text(Text, charset: String?)

  public static let gif = MediaType.image(.gif)
  public static let javascript = MediaType.application(.javascript)
  public static let jpeg = MediaType.image(.jpeg)
  public static let json = MediaType.application(.json)
  public static let mp3 = MediaType.audio(.mpeg)
  public static let png = MediaType.image(.png)

  public var description: String {
    switch self {
    case let .application(application):
      return "application/\(application)"
    case let .audio(audio):
      return "audio/\(audio)"
    case let .font(font):
      return "font/\(font)"
    case let .example(example):
      return "example/\(example)"
    case let .image(image):
      return "image/\(image)"
    case let .message(message):
      return "message/\(message)"
    case let .model(model):
      return "model/\(model)"
    case let .multipart(multipart, boundary):
      return "multipart/\(multipart)" + (boundary.map { "boundary=\($0)" } ?? "")
    case let .text(text, charset):
      return "text/\(text)" + (charset.map { "charset=\($0)" } ?? "")
    }
  }
}

public enum Application: CustomStringConvertible {
  case javascript
  case json
  case xWwwFormUrlencoded
  case other(String)

  public var description: String {
    switch self {
    case .javascript:
      return "javascript"
    case .json:
      return "json"
    case .xWwwFormUrlencoded:
      return "x-www-form-url-encoded"
    case let .other(string):
      return string
    }
  }
}

public enum Audio: CustomStringConvertible {
  case aiff
  case ogg
  case mpeg
  case wav
  case other(String)

  public var description: String {
    switch self {
    case .aiff:
      return "aiff"
    case .ogg:
      return "ogg"
    case .mpeg:
      return "mpeg"
    case .wav:
      return "wav"
    case let .other(string):
      return string
    }
  }
}

public enum Font: String {
  case collection
  case otf
  case sfnt
  case ttf
  case woff
  case woff2
}

public enum Image: CustomStringConvertible {
  case bmp
  case jpeg
  case gif
  case png
  case tiff
  case other(String)

  public var description: String {
    switch self {
    case .bmp:
      return "bmp"
    case .jpeg:
      return "jpeg"
    case .gif:
      return "gif"
    case .png:
      return "png"
    case .tiff:
      return "tiff"
    case let .other(string):
      return string
    }
  }
}

public enum Multipart: CustomStringConvertible {
  case alternative
  case digest
  case mixed
  case parallel
  case formData
  case other(String)

  public var description: String {
    switch self {
    case .alternative:
      return "alternative"
    case .digest:
      return "digest"
    case .mixed:
      return "mixed"
    case .parallel:
      return "parallel"
    case .formData:
      return "form-data"
    case let .other(string):
      return string
    }
  }
}

public enum Text: CustomStringConvertible {
  case css
  case csv
  case html
  case plain
  case other(String)

  public var description: String {
    switch self {
    case .css:
      return "css"
    case .csv:
      return "csv"
    case .html:
      return "html"
    case .plain:
      return "plain"
    case let .other(string):
      return string
    }
  }
}

public enum Video: CustomStringConvertible {
  case mp4
  case ogg
  case webm
  case other(String)

  public var description: String {
    switch self {
    case .mp4:
      return "mp4"
    case .ogg:
      return "ogg"
    case .webm:
      return "webm"
    case let .other(string):
      return string
    }
  }
}
