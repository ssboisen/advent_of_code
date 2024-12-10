input = File.stream!("./input") |> Stream.map(&String.trim_trailing/1)

split_and_parse = fn s -> for s <- String.split(s, " ", trim: true), {n, ""} = Integer.parse(s), do: n end

{xs, ys} = for s <- input, reduce: {[], []} do
  {xs, ys} ->
    [x, y] = split_and_parse.(s)
    {[ x | xs], [ y | ys]}
end

Enum.zip(Enum.sort(xs), Enum.sort(ys))
|> Enum.map(fn {x, y} -> abs(x - y) end)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

frequencies = Enum.frequencies(ys)

for x <- xs, n = Map.get(frequencies, x, 0), reduce: 0 do
  acc -> acc + x * n
end |> IO.inspect(label: "Part 2")
