input =
  File.stream!("./input")
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.map(&String.split(&1, "", trim: true))
  |> Enum.map(fn xs -> Enum.map(xs, &String.to_integer/1) end)

defmodule Day10 do
  def create_positions(input) do
    for {row, y} <- Enum.with_index(input),
        {height, x} <- Enum.with_index(row),
        into: Map.new() do
      {{x, y}, height}
    end
  end

  def find_trailheads(positions) do
    for {_, 0} = pos <- positions, do: pos
  end

  def surrounding_coords({{x, y}, _}, max_x, max_y) do
    for {dx, dy} <- [{0, -1}, {1, 0}, {0, 1}, {-1, 0}],
        {xx, yy} = {x + dx, y + dy},
        xx >= 0,
        xx <= max_x,
        yy >= 0,
        yy <= max_y do
      {xx, yy}
    end
  end

  def find_next_steps({_, height} = pos, positions, max_x, max_y) do
    for coord <- surrounding_coords(pos, max_x, max_y),
        h = Map.get(positions, coord),
        h == height + 1 do
      {coord, h}
    end
  end

  def find_trail_peaks({pos, 9}, _positions, _max_x, _max_y), do: [pos]

  def find_trail_peaks(pos, positions, max_x, max_y) do
    for next <- find_next_steps(pos, positions, max_x, max_y),
        peak <- find_trail_peaks(next, positions, max_x, max_y) do
      peak
    end
  end

  def solve(input) do
    max_x = Enum.count(Enum.at(input, 0)) - 1
    max_y = Enum.count(input) - 1

    positions = input |> create_positions()
    trailheads = positions |> find_trailheads()

    for th <- trailheads, reduce: {0, 0} do
      {rating, score} ->
        peaks = find_trail_peaks(th, positions, max_x, max_y)
        {rating + Enum.count(peaks), score + (peaks |> Enum.uniq() |> Enum.count())}
    end
  end
end

solution = input |> Day10.solve()

solution
|> elem(1)
|> IO.inspect(label: "Part 1")

solution
|> elem(0)
|> IO.inspect(label: "Part 2")
