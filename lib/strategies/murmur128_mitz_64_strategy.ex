defmodule Gloomex.BloomFilterStrategy.Murmur128MITZ64 do
  @moduledoc """
  Bloom filter using Murmur_x64_128 to hash the element.
  """
  use Bitwise

  alias Gloomex.{BitArray, Bloom, BloomFilterStrategy}

  @behaviour BloomFilterStrategy

  @seed 0
  @long_max_value trunc(:math.pow(2, 63)) - 1

  @impl true
  def put(
        %Bloom{
          num_of_hash_functions: num_of_hash_functions,
          bit_array: bit_array
        } = bloom,
        object
      ) do
    bit_size = BitArray.bit_size(bit_array)
    hash_double = Murmur.hash_x64_128(object, @seed)

    <<hash1::64, hash2::64>> = <<hash_double::128>>

    {bit_array, _} =
      Enum.reduce(1..num_of_hash_functions, {bit_array, hash1}, fn _,
                                                                   {bit_array, combined_hash} ->
        index = (combined_hash &&& @long_max_value) |> rem(bit_size)
        {BitArray.set(bit_array, index), combined_hash + hash2}
      end)

    %{bloom | bit_array: bit_array}
  end

  @impl true
  def might_contain?(
        %Bloom{
          num_of_hash_functions: num_of_hash_functions,
          bit_array: bit_array
        },
        object
      ) do
    bit_size = BitArray.bit_size(bit_array)
    hash_double = Murmur.hash_x64_128(object, @seed)

    <<hash1::64, hash2::64>> = <<hash_double::128>>

    result =
      Enum.reduce_while(1..num_of_hash_functions, hash1, fn _, combined_hash ->
        index = (combined_hash &&& @long_max_value) |> rem(bit_size)

        case !BitArray.get(bit_array, index) do
          false -> {:cont, combined_hash + hash2}
          true -> {:halt, false}
        end
      end)

    case result do
      false -> false
      _ -> true
    end
  end
end
