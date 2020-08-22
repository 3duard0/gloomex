defmodule Gloomex.GloomexTest do
  use ExUnit.Case

  alias Gloomex

  test "integration" do
    bloom = Gloomex.plain(999_999, 0.01)
    refute Gloomex.might_contain?(bloom, "oi")
    bloom = Gloomex.put!(bloom, "oi")
    assert Gloomex.might_contain?(bloom, "oi")
    refute Gloomex.might_contain?(bloom, "ocaacasi")
  end

  test "check false positive ratio (generative test)" do
    initial_amount = 10_000
    generate_amount = 90_000
    false_positive_probability = 0.01
    expected_false_positives = generate_amount * false_positive_probability
    delta = 50

    bloom = Gloomex.plain(initial_amount, false_positive_probability)

    #bloom =
      Enum.reduce(1..initial_amount, bloom, fn x, bloom ->
        Gloomex.put!(bloom, Integer.to_string(x))
      end)

    fp =
      Enum.reduce((initial_amount + 1)..(initial_amount + generate_amount), 0, fn x, fp ->
        if Gloomex.might_contain?(bloom, Integer.to_string(x)) do
          fp + 1
        else
          fp
        end
      end)

    assert expected_false_positives - delta <= fp
    assert fp <= expected_false_positives + delta
  end
end
