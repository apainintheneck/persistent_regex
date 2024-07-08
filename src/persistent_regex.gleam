import gleam/regex.{type Regex}
import internal/persistent_cache

pub fn from_string(string: String) -> Result(Regex, regex.CompileError) {
  case persistent_cache.get(key: string) {
    Ok(regex) -> Ok(regex)
    Error(_) -> {
      case regex.from_string(string) {
        Ok(regex) -> {
          persistent_cache.put(key: string, value: regex)
          Ok(regex)
        }
        err -> err
      }
    }
  }
}

pub fn assert_from_string(string: String) -> Regex {
  let assert Ok(regex) = from_string(string)
  regex
}
