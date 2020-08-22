defmodule Gloomex.ByteHelperTest do
  use ExUnit.Case
  use Bitwise

  import Gloomex.ByteHelper

  @long 0xEDDCFFCAFEBABEFF
  @long2 0xABCDEF0123456789
  @double @long2 <<< 64 ||| @long

  test "byte/2" do
    assert byte(@long, 0) == 0xFF
    assert byte(@long, 1) == 0xBE
    assert byte(@long, 2) == 0xBA
    assert byte(@long, 3) == 0xFE
    assert byte(@long, 4) == 0xCA
    assert byte(@long, 5) == 0xFF
    assert byte(@long, 6) == 0xDC
    assert byte(@long, 7) == 0xED
  end

  test "long_from_bytes/8" do
    assert long_from_bytes(0xED, 0xDC, 0xFF, 0xCA, 0xFE, 0xBA, 0xBE, 0xFF) == @long
  end

  test "lower_eight/1" do
    assert lower_eight(@double) == @long
  end

  test "upper_eight/1" do
    assert upper_eight(@double) == @long2
  end
end
