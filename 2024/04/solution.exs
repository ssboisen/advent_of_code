input =
  File.stream!("./input")
  |> Stream.map(&String.split(&1, "", trim: true))
  |> Enum.to_list()

horizontal =
  input
  |> Enum.flat_map(&Enum.chunk_every(&1, 4, 1, :discard))
  |> Enum.count(fn
    ["X", "M", "A", "S"] -> true
    ["S", "A", "M", "X"] -> true
    _ -> false
  end)
  |> IO.inspect(label: "horizontal")

vertical =
  input
  |> Enum.chunk_every(4, 1, :discard)
  |> Enum.flat_map(&Enum.zip/1)
  |> Enum.count(fn
    {"X", "M", "A", "S"} -> true
    {"S", "A", "M", "X"} -> true
    _ -> false
  end)
  |> IO.inspect(label: "vertical")

diagonal =
  input
  |> Enum.chunk_every(4, 1, :discard)
  |> Enum.flat_map(fn chunk ->
    chunk
    |> Enum.map(&Enum.chunk_every(&1, 4, 1, :discard))
    |> Enum.zip_with(fn [
                          [a, _, _, a2],
                          [_, b, b2, _],
                          [_, c, c2, _],
                          [d, _, _, d2]
                        ] ->
      [{a, b, c2, d2}, {a2, b2, c, d}]
    end)
    |> Enum.flat_map(& &1)
  end)
  |> Enum.count(fn
    {"X", "M", "A", "S"} -> true
    {"S", "A", "M", "X"} -> true
    _ -> false
  end)
  |> IO.inspect(label: "diagonal")

total = horizontal + vertical + diagonal

IO.inspect(total, label: "Part 1")

input
|> Enum.chunk_every(3, 1, :discard)
|> Enum.flat_map(fn chunk ->
  chunk
  |> Enum.map(&Enum.chunk_every(&1, 3, 1, :discard))
  |> Enum.zip_with(fn [
                        [a, _, a2],
                        [_, b, _],
                        [c, _, c2]
                      ] ->
    [{a, b, c2}, {a2, b, c}]
  end)
end)
|> Enum.count(fn crosses ->
  Enum.all?(crosses, fn
    {"M", "A", "S"} -> true
    {"S", "A", "M"} -> true
    _ -> false
  end)
end)
|> IO.inspect(label: "Part 2")
