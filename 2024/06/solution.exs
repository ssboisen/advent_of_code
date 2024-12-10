input =
  File.stream!("./input")
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.map(&(String.split(&1, "", trim: true) |> List.to_tuple()))
  |> Enum.to_list()
  |> List.to_tuple()

max_x = (input |> elem(0) |> tuple_size()) - 1
max_y = tuple_size(input) - 1

lookup = fn
  _, {x, y} when x < 0 or x > max_x or y < 0 or y > max_y ->
    nil

  input, {x, y} ->
    input |> elem(y) |> elem(x)
end

[starting_position] =
  for x <- 0..max_x, y <- 0..max_y, c = lookup.(input, {x, y}), c == "^", do: {x, y}

IO.inspect(starting_position, label: "starting_position")

move = fn
  {x, y}, :up -> {x, y - 1}
  {x, y}, :right -> {x + 1, y}
  {x, y}, :down -> {x, y + 1}
  {x, y}, :left -> {x - 1, y}
end

turn = fn
  :up -> :right
  :right -> :down
  :down -> :left
  :left -> :up
end

find_positions = fn input ->
  Stream.unfold({starting_position, :up}, fn
    {{x, y}, _} when x < 0 or x > max_x or y < 0 or y > max_y ->
      nil

    {position, direction} = current_position ->
      next_position = move.(position, direction)
      c = lookup.(input, next_position)

      if c == "#" or c == "O" do
          new_direction = turn.(direction)
          {current_position, {position, new_direction}}
      else
          {current_position, {next_position, direction}}
      end
  end)
end

# -- PART 1 --
positions = find_positions.(input)

positions
|> Enum.uniq_by(&elem(&1, 0))
|> Enum.count()
|> IO.inspect(label: "Part 1")

# -- PART 2 --

place_obstacle = fn input, x, y ->
  xs = elem(input, y)
  xs = put_elem(xs, x, "O")
  put_elem(input, y, xs)
end

has_loop = fn positions ->
  Enum.reduce_while(positions, MapSet.new(), fn position, set ->
    if MapSet.member?(set, position) do
      {:halt, true}
    else
      {:cont, set |> MapSet.put(position)}
    end
  end)
  |> then(fn
    true -> true
    _ -> false
  end)
end

for x <- 0..max_x,
    y <- 0..max_y,
    c = lookup.(input, {x, y}),
    c == ".",
    obstructed_input = place_obstacle.(input, x, y),
    positions = find_positions.(obstructed_input),
    positions |> has_loop.() do
  {x, y}
end
|> Enum.count()
|> IO.inspect(label: "Part 2")
