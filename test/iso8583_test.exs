defmodule ISO8583Test do
  use ExUnit.Case
  require Logger

  doctest ISO8583

  _ = """
  12:
  0: [0210]
  3: [000000]
  11: [000398]
  12: [092323]
  13: [0326]
  24: [002]
  37: [208509220622]
  39: [51]
  41: [00057441]
  54: [303030303030303030303030]
  """

  test "Parses bitmap" do
    message_0210_bitmap_hex = << 0x20, 0x38, 0x01, 0x00, 0x0A, 0x80, 0x04, 0x00 >>

    message_0210_bitmap_parsed = [3,11,12,13,24,37,39,41,54]
    assert message_0210_bitmap_parsed == ISO8583.parse_bitmap(message_0210_bitmap_hex)
  end

  test "Parses alphanumeric field" do
    alphanumeric_field_hex = << 0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32 >>

    assert {:ok, "208509220622"} = ISO8583.parse_field_alphanumeric(:fixed, 12, alphanumeric_field_hex)
  end

  test "Parses alphanumeric field detects overflow" do
    alphanumeric_field_hex = << 0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32 >>

    assert {:error, :too_long, _} = ISO8583.parse_field_alphanumeric(:fixed, 11, alphanumeric_field_hex)
  end

  test "Parses alphanumeric field detects field too short" do
    alphanumeric_field_hex = << 0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32 >>

    assert {:error, :too_short, _} = ISO8583.parse_field_alphanumeric(:fixed, 13, alphanumeric_field_hex)
  end

  test "Parses numeric field" do
    numeric_field_hex = << 0x00, 0x03, 0x98 >>

    assert {:ok, "000398"} = ISO8583.parse_field_numeric(:fixed, 6, numeric_field_hex)
  end

  test "Parses binary field" do
    binary_field_hex = << 0xff, 0x00, 0x32, 0xA9 >>

    assert {:ok, "FF0032A9"} = ISO8583.parse_field_binary(:fixed, 4, binary_field_hex)
  end

  test "Parses 0210 message" do

    fields_descriptors = %{
      # Message Type Indicator
      0 => %{content_type: :numeric, length_mode: :fixed, length: 4 },
      #	Processing code
      3 => %{content_type: :numeric, length_mode: :fixed, length: 6 },
      #	System trace audit number
      11 => %{content_type: :numeric, length_mode: :fixed, length: 6 },
      #	Time, local transaction (hhmmss)
      12 => %{content_type: :numeric, length_mode: :fixed, length: 6 },
      #	Date, local transaction (MMDD)
      13 => %{content_type: :numeric, length_mode: :fixed, length: 4 },
      #	Network International identifier (NII)
      24 => %{content_type: :numeric, length_mode: :fixed, length: 3 },
      #	Retrieval reference numbe
      37 => %{content_type: :alphanumeric, length_mode: :fixed, length: 12 },
      #	Response code
      39 => %{content_type: :alphanumeric, length_mode: :fixed, length: 2 },
      #	Card acceptor terminal identification
      41 => %{content_type: :alphanumeric, length_mode: :fixed, length: 8 },
      #	Additional amounts
      54 => %{content_type: :alphanumeric, length_mode: :variable_lll, length: 120 }
    }

    message_0210_hex = <<
      0x00, 0x40, 0x60, 0x14, 0x01, 0x00, 0x24,
      0x02, 0x10,
      0x20, 0x38, 0x01, 0x00, 0x0A, 0x80, 0x04, 0x00,
      0x00, 0x00, 0x00,
      0x00, 0x03, 0x98,
      0x09, 0x23, 0x23,
      0x03, 0x26,
      0x00, 0x02,
      0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32,
      0x35, 0x31,
      0x30, 0x30, 0x30, 0x35, 0x37, 0x34, 0x34, 0x31,
      0x00, 0x12,
      0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30
    >>

    message_0210_parsed = %{
      03 => "000000",
      11 => "000398",
      12 => "092323",
      13 => "0326",
      24 => "002",
      37 => "208509220622",
      39 => "51",
      41 => "00057441",
      54 => "000000000000"
    }

    assert message_0210_parsed == ISO8583.parse_message(fields_descriptors, message_0210_hex )
  end
end
