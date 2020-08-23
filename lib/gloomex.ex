defmodule Gloomex do
  @moduledoc """
  A fast and concurrent bloom filter.
  It uses `atomics` module, therefore this is a mutable structure.
  """

  alias Gloomex.BloomFilterStrategy

  @type t :: Gloomex.Bloom.t()

  defmodule Bloom do
    @moduledoc """
    A guava-like bloom filter
    """
    defstruct [
      :fpp,
      :num_of_hash_functions,
      :num_of_bits,
      :bit_array,
      :strategy
    ]

    @type t :: %Bloom{
            fpp: number,
            num_of_hash_functions: integer,
            num_of_bits: integer,
            bit_array: Gloomex.BitArray.t(),
            strategy: Gloomex.BloomFilterStrategy.t()
          }
  end

  @doc """
  Returns a plain Bloom filter based on the provided arguments:
  * `expected_insertions`, used to calculate the size of each bitvector slice
  * `fpp`, the false positive probability
  * `strategy`, strategy implementing hash function

  If a hash function is not provided then Murmur3_x64_128 will be used.
  """
  @spec plain(pos_integer(), float(), BloomFilterStrategy.t()) :: t()
  def plain(expected_insertions, fpp, strategy \\ BloomFilterStrategy.Murmur128MITZ64)
      when is_number(expected_insertions) and expected_insertions > 0 and
             is_float(fpp) and fpp > 0 and fpp < 1 do
    num_of_bits = optimal_num_of_bits(expected_insertions, fpp)
    num_of_hash_functions = optimal_num_of_hash_functions(expected_insertions, num_of_bits)

    %Bloom{
      fpp: fpp,
      num_of_hash_functions: num_of_hash_functions,
      num_of_bits: num_of_bits,
      bit_array: Gloomex.BitArray.new(num_of_bits),
      strategy: strategy
    }
  end

  @doc """
  Check if the element is in the bloom filter.
  Beware that this may be a false positive.
  There's no false negatives, i.e. if the result is false the element is not present.
  """
  @spec might_contain?(t(), any()) :: boolean()
  def might_contain?(%Bloom{strategy: strategy} = bloom, e), do: strategy.might_contain?(bloom, e)

  @doc """
  Puts in-place a new element in the bloom filter
  """
  @spec put!(t(), any()) :: t()
  def put!(%Bloom{strategy: strategy} = bloom, e), do: strategy.put!(bloom, e)

  @doc """
  Copied from Guava
  Computes the optimal k (number of hashes per element inserted in Bloom filter), given the
  expected insertions and total number of bits in the Bloom filter.

  <p>See http://en.wikipedia.org/wiki/File:Bloom_filter_fp_probability.svg for the formula.
  """
  defp optimal_num_of_hash_functions(expected_insertions, num_of_bits) do
    max(1, round(num_of_bits / expected_insertions * :math.log(2)))
  end

  @doc """
  Copied from Guava
  Computes m (total bits of Bloom filter) which is expected to achieve, for the specified
  expected insertions, the required false positive probability.

  <p>See http://en.wikipedia.org/wiki/Bloom_filter#Probability_of_false_positives for the
  formula.
  """
  defp optimal_num_of_bits(expected_insertions, fpp) do
    trunc(-expected_insertions * log2(fpp) / :math.log(2))
  end

  @spec log2(float) :: float
  defp log2(x) do
    :math.log(x) / :math.log(2)
  end
end
