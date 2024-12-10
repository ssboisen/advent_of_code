input =
  File.stream!("./input")
  |> Stream.map(&String.trim_trailing/1)
  |> Enum.map(fn l ->
    [y, xs] = String.split(l, ":", trim: true)
    xs = xs |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
    {String.to_integer(y), xs}
  end)

defmodule Day7 do
  def generate_equations([a], _), do: [[a]]
  def generate_equations([a | rest], ops) do
    for op <- ops,
        b <- generate_equations(rest, ops) do
      [a, op | b]
    end
  end

  def depth_first_calc([a | rest], ops, 0, result) do
    depth_first_calc(rest, ops, a, result)
  end

  def depth_first_calc([a], ops, acc, result) do
    for op <- ops do
      r = calc(acc, op, a)
      if result == r do
        throw(true)
      else
        r
      end
    end
  end

  def depth_first_calc([a | rest], ops, acc, result) do
    for op <- ops do
      acc = calc(acc, op, a)
      depth_first_calc(rest, ops, acc, result)
    end
  end

  def check_equation(y, xs, ops) do
    try do
      depth_first_calc(xs, ops, 0, y)
      false
    catch
      true -> true
    end
  end

  def calc(a, "+", b), do: a + b
  def calc(a, "*", b), do: a * b
  def calc(a, "||", b), do: concat(a, b)

  def concat(a, b) do
    cond do
      b < 10 -> a * 10 + b
      b < 100 -> a * 100 + b
      b < 1000 -> a * 1000 + b
      true ->
        #:math.pow(10, :math.floor(:math.log10(b)) + 1) * a + b
        String.to_integer("#{a}#{b}")
    end
  end

  def calc_equation(comb) do
    for e <- comb, reduce: {0, nil} do
      {0, nil} -> {e, nil}
      {n, nil} -> {n, e}
      {n, "+"} -> {n + e, nil}
      {n, "*"} -> {n * e, nil}
      {n, "||"} -> {concat(n,e), nil}
    end |> elem(0)
  end

  def check_equations(r, equations) do
    for equation <- equations, reduce: false do
      acc ->
        res = calc_equation(equation)
        acc or res == r
    end
  end

  def process_input(input, ops) do
    for {r, xs} <- input,
        equations = generate_equations(xs, ops),
        check_equations(r, equations),
        reduce: 0 do
      sum -> sum + r
    end
  end

  def process_input_fast(input, ops) do
    for {r, xs} <- input,
      check_equation(r, xs, ops),
      reduce: 0 do
        sum -> sum + r
      end
  end
end

timeit = fn f -> :timer.tc(f, :millisecond) end

timeit.(fn -> Day7.process_input_fast(input, ["*", "+"]) end) |> IO.inspect(label: "Part 1")
timeit.(fn -> Day7.process_input_fast(input, ["*", "+", "||"]) end) |> IO.inspect(label: "Part 2")
timeit.(fn -> Day7.process_input(input, ["*", "+"]) end) |> IO.inspect(label: "Part 1")
timeit.(fn -> Day7.process_input(input, ["*", "+", "||"]) end) |> IO.inspect(label: "Part 2")
