input = File.read!("./input")
parse_multiply = fn x, y -> String.to_integer(x) * String.to_integer(y) end

Regex.scan(~r/mul\((\d+),(\d+)\)/, input)
|> Enum.map(fn [_, x, y] -> parse_multiply.(x,y) end)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

Regex.scan(~r/do\(\)|don't\(\)|mul\((\d+),(\d+)\)/, input)
|> Enum.reduce({:do, 0}, fn
  [_, x, y], {:do, sum} -> {:do, sum + parse_multiply.(x, y)}
  ["do()"], {_, sum} -> {:do, sum}
  ["don't()"], {_, sum} -> {:donot, sum}
  _, {s, sum} -> {s, sum}
end) |> then(fn {_, sum} -> sum end) |> IO.inspect(label: "Part 2")
