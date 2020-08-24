defmodule Gloomex.BitArray do
  @moduledoc """
  This module implements a bit array using Erlang's `:array` module.
  """

  use Bitwise

  @type t :: :array.array(term)

  @long_size 64

  # long only shifts by last 6 bits (0x3F)
  @long_shift_mask 0x3F
  @long_addressable_bits 6

  @doc """
  Returns a new bitarray of size `n`.
  """
  @spec new(pos_integer) :: t
  def new(n) do
    :array.new(ceil(n / @long_size), default: 0)
  end

  @doc """
  Updates a bitarray
  """
  @spec set(t(), non_neg_integer) :: t()
  def set(a, i) do
    if get(a, i) do
      a
    else
      long_index = i >>> @long_addressable_bits
      mask = 1 <<< (i &&& @long_shift_mask)
      {_set, a} = try_exchange(a, long_index, mask)
      a
    end
  end

  defp try_exchange(a, long_index, mask) do
    old_value = :array.get(long_index, a)
    new_value = old_value ||| mask

    if old_value == new_value do
      {false, a}
    else
      {true, :array.set(long_index, new_value, a)}
    end
  end

  @doc """
  Returns `true` if the bitarray has the `i`th bit set,
  otherwise returns `false`.
  """
  @spec get(t(), non_neg_integer) :: boolean
  def get(a, i) do
    case :array.get(i >>> @long_addressable_bits, a) &&& 1 <<< (i &&& @long_shift_mask) do
      0 -> false
      _ -> true
    end
  end

  @doc """
  Amount of bits used by the atomic array
  """
  def bit_size(a) do
    :array.size(a) * @long_size
  end
end
