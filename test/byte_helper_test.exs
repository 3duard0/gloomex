defmodule Gloomex.ByteHelperTest do
  use ExUnit.Case
  use Bitwise

  import Gloomex.ByteHelper

  @long   0xeddcffcafebabeff
  @long2  0xabcdef0123456789
  @double ((@long2 <<< 64) ||| @long)

  test "byte/2" do
    assert byte(@long, 0) == 0xff
    assert byte(@long, 1) == 0xbe
    assert byte(@long, 2) == 0xba
    assert byte(@long, 3) == 0xfe
    assert byte(@long, 4) == 0xca
    assert byte(@long, 5) == 0xff
    assert byte(@long, 6) == 0xdc
    assert byte(@long, 7) == 0xed
  end

  test "long_from_bytes/8" do
    assert long_from_bytes(0xed, 0xdc, 0xff, 0xca, 0xfe, 0xba, 0xbe, 0xff) == @long
  end

  test "lower_eight/1" do
    assert lower_eight(@double) == @long
  end

  test "upper_eight/1" do
    assert upper_eight(@double) == @long2
  end
end
