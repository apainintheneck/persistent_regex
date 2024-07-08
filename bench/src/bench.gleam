import gleam/io
import gleam/list
import gleam/regex
import gleamy/bench
import persistent_regex

const valid_regex_strings = [
  "[0-9]", "^f.o.?", "^-*[0-9]+", "let (\\w+) = (\\w+)",
  "var\\s*(\\w+)\\s*(int|string)?\\s*=\\s*(.*)",
]

pub fn main() {
  bench.run(
    [
      bench.Input("x1 regex strings", valid_regex_strings),
      bench.Input(
        "x10 regex strings",
        list_multiply(valid_regex_strings, by: 10),
      ),
      bench.Input(
        "x100 regex strings",
        list_multiply(valid_regex_strings, by: 100),
      ),
      bench.Input(
        "x1000 regex strings",
        list_multiply(valid_regex_strings, by: 1000),
      ),
    ],
    [
      bench.Function("regex", list.each(_, regex.from_string)),
      bench.Function("persistent_regex", list.each(
        _,
        persistent_regex.from_string,
      )),
    ],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([
    bench.IPS,
    bench.Min,
    bench.Mean,
    bench.Max,
    bench.SDPercent,
    bench.P(99),
  ])
  |> io.println
}

fn list_multiply(list: List(a), by multiple: Int) -> List(a) {
  case multiple {
    m if m <= 1 -> list |> list.shuffle
    _ -> {
      list
      |> list.repeat(multiple)
      |> list.flatten
      |> list.shuffle
    }
  }
}
