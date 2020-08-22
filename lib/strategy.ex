defmodule Gloomex.BloomFilterStrategy do
  @moduledoc """
  """
  alias Gloomex.Bloom

  @type t :: __MODULE__

  @callback put(Bloom.t(), term()) :: Bloom.t()
  @callback might_contain?(Bloom.t(), term()) :: boolean()
end
