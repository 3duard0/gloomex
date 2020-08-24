defmodule Gloomex.BloomFilterStrategy do
  @moduledoc """
  Behaviour for a bloom filter hashing strategy
  """
  alias Gloomex.Bloom

  @type t :: __MODULE__.Murmur128MITZ64

  @callback put(Bloom.t(), term()) :: Bloom.t()
  @callback might_contain?(Bloom.t(), term()) :: boolean()
end
