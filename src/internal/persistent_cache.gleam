import gleam/regex.{type Regex}

const namespace = "persistent_regex"

type Key =
  #(String, String)

fn namespace_key(key: String) -> Key {
  #(namespace, key)
}

@target(erlang)
pub fn get(key key: String) -> Result(Regex, Nil) {
  key
  |> namespace_key
  |> do_get
}

@external(erlang, "persistent_regex_ffi", "get")
fn do_get(key: Key) -> Result(Regex, Nil)

@target(erlang)
pub fn put(key key: String, value value: Regex) -> Nil {
  key
  |> namespace_key
  |> do_put(value)
}

@external(erlang, "persistent_term", "put")
fn do_put(key: Key, value: Regex) -> Nil
