defmodule ISO8583 do
  @moduledoc """
  Documentation for `ISO8583`.
  """

  def parse_message( _ ) do
    %{ }
  end

  def parse_bitmap( bitmap_hex ) do
    parse_bitmap(bitmap_hex,1)
  end

  # If the next bit is 1, count it and recurse
  def parse_bitmap(<< 1 :: 1, rest :: bitstring >>, current_field), do: [current_field] ++ parse_bitmap(rest, current_field + 1)

  # If the next bit is 0, don't count it and recurse
  def parse_bitmap(<< 0 :: 1, rest :: bitstring >>, current_field), do: parse_bitmap(rest, current_field + 1)

  # Base case: if bits have run out, stop
  def parse_bitmap(<< >>, _), do: []

  def parse_field_alphanumeric( :fixed, length, hex ) when byte_size(hex) > length do
    {:error, :too_long, "Field too long: current length (#{byte_size(hex)}) is greater than the maximum length of: #{length}"}
  end

  def parse_field_alphanumeric( :fixed, length, hex ) when byte_size(hex) < length do
    {:error, :too_short, "Field too short: current length (#{byte_size(hex)}) is less than the minimum length of: #{length}"}
  end

  def parse_field_alphanumeric( :fixed, _, hex ) do
    {:ok, Enum.join(for <<c::utf8 <- hex>>, do: <<c::utf8>>)}
  end
end
