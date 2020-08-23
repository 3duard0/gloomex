defmodule Gloomex.BitArray do
  @moduledoc """
  This module implements a bit array using Erlang's `:atomics` module.
  This structure is mutable, but concurrent and space efficient.
  """

  use Bitwise

  import Gloomex.ByteHelper

  @type t :: :atomics.atomics_ref()

  @long_size 64
  @long_shift_mask 0x3F
  @long_addressable_bits 6

  @doc """
  Returns a new bitarray of size `n`.
  """
  @spec new(pos_integer) :: t
  def new(n) do
    :atomics.new(ceil(n / @long_size), signed: false)
  end

  @doc """
  Updates in-place a bitarray
  """
  @spec set!(t(), non_neg_integer) :: t()
  def set!(a, i) do
    if get(a, i) do
      a
    else
      long_index = i >>> @long_addressable_bits
      {_set, a} = try_exchange(a, long_index, 1 <<< (i &&& @long_shift_mask))
      a
    end
  end

  defp try_exchange(a, long_index, mask) do
    old_value = :atomics.get(a, long_index + 1)
    new_value = old_value ||| mask

    cond do
      old_value == new_value ->
        {false, a}

      :atomics.compare_exchange(a, long_index + 1, old_value, new_value) == :ok ->
        {true, a}

      true ->
        try_exchange(a, long_index, mask)
    end
  end

  @doc """
  Returns `true` if the bitarray has the `i`th bit set,
  otherwise returns `false`.
  """
  @spec get(t(), non_neg_integer) :: boolean
  def get(a, i) do
    case :atomics.get(a, (i >>> @long_addressable_bits) + 1) &&& 1 <<< (i &&& @long_shift_mask) do
      0 -> false
      _ -> true
    end
  end

  @doc """
  Amount of bits used by the atomic array
  """
  def bit_size(a) do
    :atomics.info(a).size() * @long_size
  end
end
