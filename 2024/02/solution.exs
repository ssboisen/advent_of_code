defmodule Day2 do
  def check_levels([x, y | rest] = _levels) when x < y and y - x <= 3 do
    do_check(rest, y, :gt)
  end

  def check_levels([x, y | rest] = _levels) when x > y and x - y <= 3 do
    do_check(rest, y, :lt)
  end

  def check_levels(_), do: :unsafe

  defp do_check([y | tail], x, :gt) when x < y and y - x <= 3 do
    do_check(tail, y, :gt)
  end

  defp do_check([y | tail], x, :lt) when x > y and x - y <= 3 do
    do_check(tail, y, :lt)
  end

  defp do_check([], _, _), do: :safe
  defp do_check(_, _, _), do: :unsafe
end

parse! = &String.to_integer/1

reports =
  File.stream!("./input")
  |> Stream.map(&String.split/1)
  |> Stream.map(&Enum.map(&1, parse!))

reports
|> Stream.map(&Day2.check_levels/1)
|> Enum.count(&match?(:safe, &1))
|> IO.inspect(label: "Part 1 Safe reports")

reports
|> Stream.filter(fn levels ->
  levels
  |> Enum.with_index()
  |> Enum.any?(fn {_, i} -> Day2.check_levels(List.delete_at(levels, i)) == :safe end)
end)
|> Enum.count()
|> IO.inspect(label: "Part 2 Safe reports")
