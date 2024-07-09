# persistent_regex

This is a library which persists regexes on Erlang so that they don't have to be recompiled each time `regex.from_string`
is called. It uses [persistent_term](https://erlang.org/doc/apps/erts/persistent_term.html)
internally to save compiled regexes. On JavaScript it defaults to the [stdlib](https://github.com/gleam-lang/stdlib)
`regex.from_string` implementation because benchmarks have shown that there is no performance benefit (see `bench/README.md` for more info).
The JavaScript implementation is just there to allow for better ergonomics when using this library in cross-target code.

Ultimately I made this library to explore how persisting regexes in Gleam affected performance (see https://github.com/gleam-lang/gleam/discussions/3374)
so for that reason I don't plan on publishing it anywhere. Maybe I'll rethink it if I actually need it for a project.

```gleam
import gleam/regex
import persistent_regex

pub fn main() {
  let assert Ok(regex) = persistent_regex.from_string("[A-Z]+")
  let confident_regex = persistent_regex.assert_from_string("[A-Z]+")

  regex.scan(regex, "take me to your CAPITAL!")

  // do work
}
```
