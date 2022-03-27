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

  test "Parses 0210 message" do
    # ISO8583 - 1987
    fields_descriptors = %{
      "MTI" => %{
        label: "Message Type Indicator",
        content_type: :numeric,
        length_mode: :fixed,
        length: 4
      },
      2 => %{
        label: "Primary account number (PAN)",
        content_type: :numeric,
        length_mode: :variable_ll,
        length: 19
      },
      3 => %{label: "Processing Code", content_type: :numeric, length_mode: :fixed, length: 6},
      4 => %{
        label: "Amount, transaction",
        content_type: :numeric,
        length_mode: :fixed,
        length: 12
      },
      5 => %{label: "Amount, settlement", content_type: :numeric, length_mode: :fixed, length: 12},
      6 => %{
        label: "Amount, cardholder billing",
        content_type: :numeric,
        length_mode: :fixed,
        length: 12
      },
      7 => %{
        label: "Amount, Transmission date & time (mmddhhmmss)",
        content_type: :numeric,
        length_mode: :fixed,
        length: 10
      },
      8 => %{
        label: "Amount, cardholder billing fee",
        content_type: :numeric,
        length_mode: :fixed,
        length: 8
      },
      9 => %{
        label: "Conversion rate, settlement",
        content_type: :numeric,
        length_mode: :fixed,
        length: 8
      },
      10 => %{
        label: "Conversion rate, cardholder billing",
        content_type: :numeric,
        length_mode: :fixed,
        length: 8
      },
      11 => %{
        label: "System trace audit number",
        content_type: :numeric,
        length_mode: :fixed,
        length: 6
      },
      12 => %{
        label: "Time, local transaction (hhmmss)",
        content_type: :numeric,
        length_mode: :fixed,
        length: 6
      },
      13 => %{
        label: "Date, local transaction (MMDD)",
        content_type: :numeric,
        length_mode: :fixed,
        length: 4
      },
      14 => %{
        label: "Date, expiration (YYMM)",
        content_type: :numeric,
        length_mode: :fixed,
        length: 4
      },
      15 => %{label: "Date, settlement", content_type: :numeric, length_mode: :fixed, length: 4},
      16 => %{
        label: "Date, conversion (MMDD)",
        content_type: :numeric,
        length_mode: :fixed,
        length: 4
      },
      17 => %{
        label: "Date, capture (MMDD)",
        content_type: :numeric,
        length_mode: :fixed,
        length: 4
      },
      18 => %{label: "Merchant's type", content_type: :numeric, length_mode: :fixed, length: 4},
      19 => %{
        label: "Acquiring institution country code",
        content_type: :numeric,
        length_mode: :fixed,
        length: 3
      },
      20 => %{
        label: "Primary account number extended country code",
        content_type: :numeric,
        length_mode: :fixed,
        length: 3
      },
      21 => %{
        label: "Forwarding institution country code",
        content_type: :numeric,
        length_mode: :fixed,
        length: 3
      },
      22 => %{
        label: "Point of service entry mode",
        content_type: :numeric,
        length_mode: :fixed,
        length: 3
      },
      23 => %{
        label: "Application card sequence number",
        content_type: :numeric,
        length_mode: :fixed,
        length: 3
      },
      24 => %{
        label: "Network International identifier (NII)",
        content_type: :numeric,
        length_mode: :fixed,
        length: 3
      },
      25 => %{
        label: "Point of service condition code",
        content_type: :numeric,
        length_mode: :fixed,
        length: 2
      },
      26 => %{
        label: "Point of service capture code",
        content_type: :numeric,
        length_mode: :fixed,
        length: 2
      },
      27 => %{
        label: "Authorizing identification response length",
        content_type: :numeric,
        length_mode: :fixed,
        length: 1
      },
      28 => %{
        label: "Amount, transaction fee",
        content_type: :x_numeric,
        length_mode: :fixed,
        length: 8
      },
      29 => %{
        label: "Amount, settlement fee",
        content_type: :x_numeric,
        length_mode: :fixed,
        length: 8
      },
      30 => %{
        label: "Amount, transaction processing fee",
        content_type: :x_numeric,
        length_mode: :fixed,
        length: 8
      },
      31 => %{
        label: "Amount, settlement processing fee",
        content_type: :x_numeric,
        length_mode: :fixed,
        length: 8
      },
      32 => %{
        label: "Acquiring institution identification code",
        content_type: :numeric,
        length_mode: :variable_ll,
        length: 11
      },
      33 => %{
        label: "Forwarding institution identification codee",
        content_type: :numeric,
        length_mode: :variable_ll,
        length: 11
      },
      34 => %{
        label: "Primary account number, extended",
        content_type: :numeric,
        length_mode: :variable_ll,
        length: 28
      },
      35 => %{
        label: "Track 2 data",
        content_type: :track_2,
        length_mode: :variable_ll,
        length: 37
      },
      36 => %{
        label: "Track 3 data",
        content_type: :numeric,
        length_mode: :variable_ll,
        length: 104
      },
      37 => %{
        label: "Retrieval reference number",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 12
      },
      38 => %{
        label: "Authorization identification response",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 6
      },
      39 => %{
        label: "Response code",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 2
      },
      40 => %{
        label: "Service restriction code",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 3
      },
      41 => %{
        label: "Card acceptor terminal identification",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 8
      },
      42 => %{
        label: "Card acceptor identification code",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 15
      },
      43 => %{
        label: "Card acceptor name/location (1-23 address 24-36 city 37-38 state 39-40 country",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 40
      },
      44 => %{
        label: "Additional response data",
        content_type: :alphanumeric,
        length_mode: :variable_ll,
        length: 25
      },
      45 => %{
        label: "Track 1 data",
        content_type: :alphanumeric,
        length_mode: :variable_ll,
        length: 76
      },
      46 => %{
        label: "Additional data - ISO",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      47 => %{
        label: "Additional data - National",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      48 => %{
        label: "Additional data - Private",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      49 => %{
        label: "Currency code, transaction",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 3
      },
      50 => %{
        label: "Currency code, settlement",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 3
      },
      51 => %{
        label: "Currency code, cardholder billing",
        content_type: :alphanumeric,
        length_mode: :fixed,
        length: 3
      },
      52 => %{
        label: "Personal identification number data",
        content_type: :binary,
        length_mode: :fixed,
        length: 64
      },
      53 => %{
        label: "Security related control information",
        content_type: :numeric,
        length_mode: :fixed,
        length: 16
      },
      54 => %{
        label: "Additional amounts",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 120
      },
      55 => %{
        label: "Reserved ISO",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      56 => %{
        label: "Reserved ISO",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      57 => %{
        label: "Reserved ISO",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      58 => %{
        label: "Reserved ISO",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      59 => %{
        label: "Reserved ISO",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      60 => %{
        label: "Reserved ISO",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      61 => %{
        label: "Reserved private",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      62 => %{
        label: "Reserved private",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      63 => %{
        label: "Reserved private",
        content_type: :alphanumeric,
        length_mode: :variable_lll,
        length: 999
      },
      64 => %{
        label: "Message authentication code (MAC)",
        content_type: :binary,
        length_mode: :fixed,
        length: 16
      }
    }

    message_0210_hex = <<
      0x00,
      0x40,
      0x60,
      0x14,
      0x01,
      0x00,
      0x24,
      0x02,
      0x10,
      0x20,
      0x38,
      0x01,
      0x00,
      0x0A,
      0x80,
      0x04,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x03,
      0x98,
      0x09,
      0x23,
      0x23,
      0x03,
      0x26,
      0x00,
      0x02,
      0x32,
      0x30,
      0x38,
      0x35,
      0x30,
      0x39,
      0x32,
      0x32,
      0x30,
      0x36,
      0x32,
      0x32,
      0x35,
      0x31,
      0x30,
      0x30,
      0x30,
      0x35,
      0x37,
      0x34,
      0x34,
      0x31,
      0x00,
      0x12,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30
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

    assert message_0210_parsed == ISO8583.parse_message(fields_descriptors, message_0210_hex)
  end
end
