input =
  File.read!("./input")
  |> String.trim_trailing()
  |> String.split("", trim: true)
  |> Enum.map(&String.to_integer/1)

defmodule Day9 do
  defmodule Part1 do
    def find_file_blocks(input) do
      input
      |> Enum.with_index()
      |> Enum.flat_map_reduce(0, fn
        {n, i}, file_id when rem(i, 2) == 0 ->
          {List.duplicate(file_id, n), file_id + 1}

        {n, _}, file_id ->
          {List.duplicate(:free, n), file_id}
      end)
      |> elem(0)
    end

    def compact(file_blocks, reverse_file_blocks, checksum \\ 0)

    def compact([{_, i} | _], [{_, j} | _], checksum) when i > j do
      checksum
    end

    def compact([{:free, _} | _] = file_blocks, [{:free, _} | reverse_file_blocks], checksum) do
      compact(file_blocks, reverse_file_blocks, checksum)
    end

    def compact([{:free, i} | file_blocks], [{n, _} | reverse_file_blocks], checksum) do
      compact(file_blocks, reverse_file_blocks, checksum + n * i)
    end

    def compact([{n, i} | file_blocks], reverse_file_blocks, checksum) do
      compact(file_blocks, reverse_file_blocks, checksum + n * i)
    end

    def solve(input) do
      file_blocks = find_file_blocks(input) |> Enum.with_index()
      compact(file_blocks, Enum.reverse(file_blocks))
    end
  end

  defmodule Part2 do
    def find_file_blocks(input) do
      input
      |> Enum.with_index()
      |> Enum.flat_map_reduce({0, 0}, fn
        {n, i}, {file_id, index} when rem(i, 2) == 0 ->
          {[{file_id, index, n}], {file_id + 1, index + n}}

        {n, _}, {file_id, index} when n > 0 ->
          {[{:free, index, n}], {file_id, index + n}}

        {n, _}, {file_id, index} ->
          {[], {file_id, index + n}}
      end)
      |> elem(0)
    end

    def compact(file_blocks) do
      for {file_id, j, size} when file_id != :free <- Enum.reverse(file_blocks),
          reduce: file_blocks do
        file_blocks ->
          Enum.flat_map_reduce(file_blocks, :unchanged, fn
            {:free, i, ^size}, :unchanged when i < j ->
              {[{file_id, i, size}], :changed}

            {:free, i, free_size}, :unchanged when size < free_size and i < j ->
              {[{file_id, i, size}, {:free, i + size, free_size - size}], :changed}

            {^file_id, i, size}, :changed ->
              {[{:free, i, size}], :changed}

            file_block, state ->
              {[file_block], state}

          end)
          |> elem(0)
      end
      |> Enum.flat_map(fn 
        {:free, _, _ } -> [0]
        {file_id, i, n} -> for x <- i..(i + n - 1), do: x * file_id
      end)
      |> Enum.sum()
    end

    def solve(input) do
      file_blocks = find_file_blocks(input)
      compact(file_blocks)
    end

  end
end

Day9.Part1.solve(input) |> IO.inspect(label: "Part 1")

Day9.Part2.solve(input) |> IO.inspect(label: "Part 2")
