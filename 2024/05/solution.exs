input = File.stream!("./input") |> Stream.map(&String.trim_trailing/1)
parse! = &String.to_integer/1

rules =
  input
  |> Stream.filter(&String.contains?(&1, "|"))
  |> Stream.map(&(String.split(&1, "|", trim: true) |> Enum.map(parse!)))
  |> Enum.to_list()
  |> Enum.reduce(Map.new(), fn [a, b], m ->
    Map.update(m, a, MapSet.new([b]), &MapSet.put(&1, b))
  end)

updates =
  input
  |> Stream.filter(&String.contains?(&1, ","))
  |> Stream.map(&(String.split(&1, ",", trim: true) |> Enum.map(parse!)))
  |> Enum.to_list()

middle = fn l -> Enum.at(l, round(Enum.count(l) / 2 - 1)) end

sorter = fn a, b ->
  ruleset = Map.fetch!(rules, a)
  MapSet.member?(ruleset, b)
end

for update <- updates, reduce: 0 do
  sum ->
    sorted_update = update |> Enum.sort(sorter)

    if sorted_update == update do
      sum + middle.(sorted_update)
    else
      sum
    end
end
|> IO.inspect(label: "Part 1")

for update <- updates, reduce: 0 do
  sum ->
    sorted_update = update |> Enum.sort(sorter)

    if sorted_update != update do
      sum + middle.(sorted_update)
    else
      sum
    end
end
|> IO.inspect(label: "Part 2")
