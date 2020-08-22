defmodule Gloomex.ByteHelper do
  use Bitwise

  defmacro byte(long, ix) do
    quote bind_quoted: [long: long, ix: ix] do
      (long >>> (8 * ix)) &&& 0xff
    end
  end

  defmacro long_from_bytes(b7, b6, b5, b4, b3, b2, b1, b0) do
    quote bind_quoted: [b7: b7, b6: b6, b5: b5, b4: b4, b3: b3, b2: b2, b1: b1, b0: b0] do
      (b7 <<< 56) |||
        (b6 <<< 48) |||
        (b5 <<< 40) |||
        (b4 <<< 32) |||
        (b3 <<< 24) |||
        (b2 <<< 16) |||
        (b1 <<< 8) |||
        b0
    end
  end

  def lower_eight(double) do
    long_from_bytes(
      byte(double, 7),
      byte(double, 6),
      byte(double, 5),
      byte(double, 4),
      byte(double, 3),
      byte(double, 2),
      byte(double, 1),
      byte(double, 0))
  end

  def upper_eight(double) do
    long_from_bytes(
      byte(double, 15),
      byte(double, 14),
      byte(double, 13),
      byte(double, 12),
      byte(double, 11),
      byte(double, 10),
      byte(double, 9),
      byte(double, 8))
  end
end
