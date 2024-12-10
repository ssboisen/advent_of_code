input = File.stream!("./input")

map =
  input
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.map(&String.split(&1, "", trim: true))
  |> Enum.to_list()

max_x = Enum.count(Enum.at(map, 0)) - 1
max_y = Enum.count(map) - 1

within_map = fn {x, y} -> x >= 0 and x <= max_x and y >= 0 and y <= max_y end

antenna_coords =
  for {row, y} <- Enum.with_index(map),
      {c, x} <- Enum.with_index(row),
      c != ".",
      reduce: %{} do
    acc -> Map.update(acc, c, [{x, y}], &[{x, y} | &1])
  end
  |> Map.values()

antinodes =
  for coords <- antenna_coords,
      {x1, y1} = a <- coords,
      {x2, y2} = b <- coords,
      a < b,
      {dx, dy} = {x1 - x2, y1 - y2},
      antinode <- [{x1 + dx, y1 + dy}, {x2 - dx, y2 - dy}],
      within_map.(antinode),
      uniq: true do
    antinode
  end

antinodes
|> Enum.count()
|> IO.inspect(label: "Part 1")

antinodes =
  for coords <- antenna_coords,
      {x1, y1} = a <- coords,
      {x2, y2} = b <- coords,
      a < b,
      {dx, dy} = {x1 - x2, y1 - y2},
      f <- 1..max(max_x, max_y),
      antinode <- [{x1 - dx * f, y1 - dy * f}, {x2 + dx * f, y2 + dy * f}],
      within_map.(antinode),
      uniq: true do
    antinode
  end

antinodes
|> Enum.count()
|> IO.inspect(label: "Part 2")
