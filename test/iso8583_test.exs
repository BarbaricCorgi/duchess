defmodule ISO8583Test do
  use ExUnit.Case
  require Logger

  doctest ISO8583

  test "Parses bitmap" do
    message_0210_bitmap_hex = <<0x20, 0x38, 0x01, 0x00, 0x0A, 0x80, 0x04, 0x00>>

    message_0210_bitmap_parsed = [3, 11, 12, 13, 24, 37, 39, 41, 54]
    assert message_0210_bitmap_parsed == ISO8583.parse_bitmap(message_0210_bitmap_hex)
  end

  test "Parses alphanumeric field" do
    alphanumeric_field_hex =
      <<0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32>>

    assert {:ok, "208509220622"} =
             ISO8583.parse_field_alphanumeric(:fixed, 12, alphanumeric_field_hex)
  end

  test "Parses alphanumeric field detects overflow" do
    alphanumeric_field_hex =
      <<0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32>>

    assert {:error, :too_long, _} =
             ISO8583.parse_field_alphanumeric(:fixed, 11, alphanumeric_field_hex)
  end

  test "Parses alphanumeric field detects field too short" do
    alphanumeric_field_hex =
      <<0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32>>

    assert {:error, :too_short, _} =
             ISO8583.parse_field_alphanumeric(:fixed, 13, alphanumeric_field_hex)
  end

  test "Parses numeric field" do
    numeric_field_hex = <<0x00, 0x03, 0x98>>

    assert {:ok, "000398"} = ISO8583.parse_field_numeric(:fixed, 6, numeric_field_hex)
  end

  test "Parses binary field" do
    binary_field_hex = <<0xFF, 0x00, 0x32, 0xA9>>

    assert {:ok, "FF0032A9"} = ISO8583.parse_field_binary(:fixed, 4, binary_field_hex)
  end

  test "Parses 0200 message" do
    message_0200_hex =
      <<0x00, 0x8B, 0x60, 0x00, 0x24, 0x14, 0x01, 0x02, 0x00, 0x32, 0x38, 0x05, 0x80, 0x20, 0xC1,
        0x80, 0x1E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x28, 0x00, 0x03, 0x26, 0x09, 0x23,
        0x45, 0x00, 0x04, 0x62, 0x09, 0x23, 0x45, 0x03, 0x26, 0x00, 0x21, 0x00, 0x02, 0x00, 0x37,
        0x46, 0x29, 0x93, 0x00, 0x06, 0x14, 0x31, 0x36, 0xD2, 0x01, 0x21, 0x21, 0x10, 0x22, 0x22,
        0x72, 0x00, 0x00, 0x0F, 0x30, 0x30, 0x30, 0x32, 0x36, 0x39, 0x32, 0x34, 0x30, 0x30, 0x30,
        0x30, 0x30, 0x30, 0x34, 0x30, 0x34, 0x36, 0x37, 0x39, 0x30, 0x30, 0x31, 0x00, 0x03, 0x30,
        0x30, 0x31, 0x32, 0x31, 0x34, 0x00, 0x11, 0x43, 0x41, 0x54, 0x43, 0x48, 0x45, 0x52, 0x20,
        0x32, 0x2E, 0x30, 0x00, 0x06, 0x30, 0x30, 0x30, 0x30, 0x30, 0x31, 0x00, 0x06, 0x30, 0x30,
        0x30, 0x30, 0x31, 0x31, 0x00, 0x15, 0x34, 0x31, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x30, 0x30, 0x30, 0x30, 0x30, 0x43>>

    message_0200_parsed = %{
      3 => "000000",
      4 => "000000022800",
      7 => "0326092345",
      11 => "000462",
      12 => "092345",
      13 => "0326",
      22 => "021",
      24 => "002",
      25 => "00",
      35 => "4629930006143136=20121211022227200000",
      41 => "00026924",
      42 => "000000404679001",
      48 => "001",
      49 => "214",
      60 => "CATCHER 2.0",
      61 => "000001",
      62 => "000011",
      63 => "41000000000000C",
      :MTI => "0200"
    }

    assert message_0200_parsed == ISO8583.parse_message(message_0200_hex)
  end

  test "Parses 0210 message" do
    message_0210_hex =
      <<0x00, 0x40, 0x60, 0x14, 0x01, 0x00, 0x24, 0x02, 0x10, 0x20, 0x38, 0x01, 0x00, 0x0A, 0x80,
        0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x98, 0x09, 0x23, 0x23, 0x03, 0x26, 0x00, 0x02,
        0x32, 0x30, 0x38, 0x35, 0x30, 0x39, 0x32, 0x32, 0x30, 0x36, 0x32, 0x32, 0x35, 0x31, 0x30,
        0x30, 0x30, 0x35, 0x37, 0x34, 0x34, 0x31, 0x00, 0x12, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x30, 0x30, 0x30, 0x30, 0x30, 0x30>>

    message_0210_parsed = %{
      03 => "000000",
      11 => "000398",
      12 => "092323",
      13 => "0326",
      24 => "002",
      37 => "208509220622",
      39 => "51",
      41 => "00057441",
      54 => "000000000000",
      :MTI => "0210"
    }

    assert message_0210_parsed == ISO8583.parse_message(message_0210_hex)
  end

  test "Parses 0500 message" do
    message_0500_hex =
      <<0x00, 0x7F, 0x60, 0x00, 0x24, 0x14, 0x06, 0x05, 0x00, 0x22, 0x22, 0x01, 0x00, 0x00, 0xC0,
        0x00, 0x16, 0x92, 0x00, 0x00, 0x03, 0x26, 0x09, 0x22, 0x52, 0x00, 0x03, 0x67, 0x03, 0x26,
        0x00, 0x02, 0x4D, 0x38, 0x30, 0x30, 0x33, 0x36, 0x32, 0x31, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x30, 0x34, 0x33, 0x34, 0x32, 0x36, 0x38, 0x30, 0x30, 0x31, 0x00, 0x11, 0x43, 0x41, 0x54,
        0x43, 0x48, 0x45, 0x52, 0x20, 0x32, 0x2E, 0x30, 0x00, 0x06, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x33, 0x00, 0x51, 0x31, 0x32, 0x30, 0x30, 0x30, 0x30, 0x32, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x30, 0x34, 0x35, 0x31, 0x39, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30>>

    message_0500_parsed = %{
      3 => "920000",
      11 => "000367",
      24 => "002",
      41 => "M8003621",
      7 => "0326092252",
      15 => "0326",
      42 => "000000434268001",
      60 => "CATCHER 2.0",
      62 => "000003",
      63 => "120000200000045190000000000000000000000000000000000",
      :MTI => "0500"
    }

    assert message_0500_parsed == ISO8583.parse_message(message_0500_hex)
  end

  test "Parses 0510 message" do
    message_0510_hex =
      <<0x00, 0x43, 0x60, 0x14, 0x06, 0x00, 0x24, 0x05, 0x10, 0x20, 0x38, 0x01, 0x00, 0x0A, 0x80,
        0x00, 0x02, 0x92, 0x00, 0x00, 0x00, 0x03, 0x67, 0x09, 0x18, 0x46, 0x03, 0x26, 0x00, 0x02,
        0x32, 0x30, 0x38, 0x35, 0x37, 0x37, 0x34, 0x30, 0x30, 0x37, 0x31, 0x36, 0x30, 0x30, 0x4D,
        0x38, 0x30, 0x30, 0x33, 0x36, 0x32, 0x31, 0x00, 0x15, 0x43, 0x49, 0x45, 0x52, 0x52, 0x45,
        0x20, 0x43, 0x4F, 0x4D, 0x50, 0x4C, 0x45, 0x54, 0x4F>>

    message_0510_parsed = %{
      3 => "920000",
      11 => "000367",
      24 => "002",
      41 => "M8003621",
      63 => "CIERRE COMPLETO",
      12 => "091846",
      13 => "0326",
      37 => "208577400716",
      39 => "00",
      :MTI => "0510"
    }

    assert message_0510_parsed == ISO8583.parse_message(message_0510_hex)
  end

  test "Parses track2" do
    track2_field_hex =
      <<0x46, 0x29, 0x93, 0x00, 0x06, 0x14, 0x31, 0x36, 0xD2, 0x01, 0x21, 0x21, 0x10, 0x22, 0x22,
        0x72, 0x00, 0x00, 0x0F>>

    assert {:ok, "4629930006143136=20121211022227200000"} =
             ISO8583.parse_field_track2(:variable_ll, 37, track2_field_hex)
  end

  test "Inspects a message" do
    message_0510_parsed = %{
      3 => "920000",
      11 => "000367",
      24 => "002",
      41 => "M8003621",
      63 => "CIERRE COMPLETO",
      12 => "091846",
      13 => "0326",
      37 => "208577400716",
      39 => "00",
      :MTI => "0510"
    }

    assert "Processing Code
Field 3: 920000

System trace audit number
Field 11: 000367

Time, local transaction (hhmmss)
Field 12: 091846

Date, local transaction (MMDD)
Field 13: 0326

Network International identifier (NII)
Field 24: 002

Retrieval reference number
Field 37: 208577400716

Response code
Field 39: 00

Card acceptor terminal identification
Field 41: M8003621

Reserved private
Field 63: CIERRE COMPLETO

Message Type Indicator
Field MTI: 0510" == ISO8583.inspect(message_0510_parsed)
  end
end
