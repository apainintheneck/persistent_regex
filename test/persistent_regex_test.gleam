import gleam/list
import gleam/regex
import gleeunit
import gleeunit/should
import internal/persistent_cache
import persistent_regex

pub fn main() {
  gleeunit.main()
}

const valid_regex_strings = [
  "[0-9]", "^f.o.?", "^-*[0-9]+", "let (\\w+) = (\\w+)",
  "var\\s*(\\w+)\\s*(int|string)?\\s*=\\s*(.*)",
]

@target(erlang)
pub fn valid_from_string_test() {
  valid_regex_strings
  |> list.each(fn(regex_string) {
    persistent_cache.get(regex_string)
    |> should.be_error

    persistent_regex.from_string(regex_string)
    |> should.equal(regex.from_string(regex_string))

    persistent_cache.get(regex_string)
    |> should.be_ok

    persistent_regex.from_string(regex_string)
    |> should.equal(regex.from_string(regex_string))

    persistent_cache.get(regex_string)
    |> should.be_ok
  })
}

const invalid_regex_strings = ["[0-9", "..0-9)", "(\\w([a-z]+)"]

@target(erlang)
pub fn invalid_from_string_test() {
  invalid_regex_strings
  |> list.each(fn(regex_string) {
    persistent_cache.get(regex_string)
    |> should.be_error

    persistent_regex.from_string(regex_string)
    |> should.equal(regex.from_string(regex_string))

    persistent_cache.get(regex_string)
    |> should.be_error

    persistent_regex.from_string(regex_string)
    |> should.equal(regex.from_string(regex_string))

    persistent_cache.get(regex_string)
    |> should.be_error
  })
}

pub fn matches_regex_from_string_test() {
  [valid_regex_strings, invalid_regex_strings]
  |> list.concat
  |> list.each(fn(regex_string) {
    persistent_regex.from_string(regex_string)
    |> should.equal(regex.from_string(regex_string))
  })
}
