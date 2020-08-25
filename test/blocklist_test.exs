defmodule Gloomex.BlocklistTest do
  @moduledoc """
  Tests if the bloom filter remains compatible with guava, generating the same false positives,
  true negatives and true positives.

  As all true positives are contained in the filter we prove that we have no false negatives
  (at least for this blocklist).
  """
  use ExUnit.Case

  @blocklist_file "#{__DIR__}/resources/top1000000.txt"
  @false_positives "#{__DIR__}/resources/false-positives.txt"
  @true_negatives "#{__DIR__}/resources/true-negatives.txt"

  describe "check true negatives, false positives and true positives" do
    setup do
      {:ok, filter: Gloomex.plain_from_file(@blocklist_file, 0.01)}
    end

    test "true positives", %{filter: filter} do
      @blocklist_file
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.each(fn fp ->
        assert Gloomex.might_contain?(filter, fp)
      end)
    end

    test "false positives", %{filter: filter} do
      @false_positives
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.each(fn fp ->
        assert Gloomex.might_contain?(filter, fp)
      end)
    end

    test "true negatives", %{filter: filter} do
      @true_negatives
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.each(fn tn ->
        refute Gloomex.might_contain?(filter, tn)
      end)
    end
  end
end
