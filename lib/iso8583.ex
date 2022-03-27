defmodule ISO8583 do
  @moduledoc """
  Documentation for `ISO8583`.
  """
  require Logger

  # ISO8583 - 1987
  @fields_descriptors %{
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

  def parse_message(message_hex) do
    <<_::binary-size(7), mti_rest::bitstring>> = message_hex
    <<_::binary-size(2), header_rest::bitstring>> = mti_rest
    <<bitmap_hex::binary-size(8), bitmap_rest::bitstring>> = header_rest
    bitmap = parse_bitmap(bitmap_hex)

    parse_fields(
      bitmap,
      bitmap_rest,
      %{},
      @fields_descriptors[List.first(bitmap)][:content_type],
      @fields_descriptors[List.first(bitmap)][:length_mode]
    )
  end

  # Base case: if bits have run out, stop
  def parse_fields([], _, result_map, _, _), do: result_map

  def parse_fields(fields_list, hex, result_map, :numeric, :fixed) do
    [current_field | other_fields] = fields_list

    field_size = ceil(@fields_descriptors[current_field][:length] / 2)
    <<current_hex::binary-size(field_size), rest_hex::bitstring>> = hex

    {:ok, field_value} =
      parse_field_numeric(
        @fields_descriptors[current_field][:length_mode],
        @fields_descriptors[current_field][:length],
        current_hex
      )

    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(
      other_fields,
      rest_hex,
      result_map,
      @fields_descriptors[List.first(other_fields)][:content_type],
      @fields_descriptors[List.first(other_fields)][:length_mode]
    )
  end

  def parse_fields(fields_list, hex, result_map, :track_2, :variable_ll) do
    [current_field | other_fields] = fields_list
    <<size::binary-size(1), size_rest_hex::bitstring>> = hex

    padded_size = Bcd.decode(<<0, 0, 0>> <> size)
    ceil_size = ceil(padded_size / 2)
    <<field_hex::binary-size(ceil_size), rest_hex::bitstring>> = size_rest_hex

    {:ok, field_value} =
      parse_field_track2(
        @fields_descriptors[current_field][:length_mode],
        padded_size,
        field_hex
      )

    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(
      other_fields,
      rest_hex,
      result_map,
      @fields_descriptors[List.first(other_fields)][:content_type],
      @fields_descriptors[List.first(other_fields)][:length_mode]
    )
  end

  def parse_fields(fields_list, hex, result_map, :numeric, :variable_ll) do
    [current_field | other_fields] = fields_list

    <<size::binary-size(1), size_rest_hex::bitstring>> = hex

    padded_size = Bcd.decode(<<0, 0, 0>> <> size)
    <<field_hex::binary-size(padded_size), rest_hex::bitstring>> = size_rest_hex

    {:ok, field_value} =
      parse_field_numeric(
        @fields_descriptors[current_field][:length_mode],
        padded_size,
        field_hex
      )

    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(
      other_fields,
      rest_hex,
      result_map,
      @fields_descriptors[List.first(other_fields)][:content_type],
      @fields_descriptors[List.first(other_fields)][:length_mode]
    )
  end

  def parse_fields(fields_list, hex, result_map, :numeric, :variable_lll) do
    [current_field | other_fields] = fields_list

    <<size::binary-size(2), size_rest_hex::bitstring>> = hex

    padded_size = Bcd.decode(<<0, 0>> <> size)
    <<field_hex::binary-size(padded_size), rest_hex::bitstring>> = size_rest_hex

    {:ok, field_value} =
      parse_field_numeric(
        @fields_descriptors[current_field][:length_mode],
        padded_size,
        field_hex
      )

    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(
      other_fields,
      rest_hex,
      result_map,
      @fields_descriptors[List.first(other_fields)][:content_type],
      @fields_descriptors[List.first(other_fields)][:length_mode]
    )
  end

  def parse_fields(fields_list, hex, result_map, :alphanumeric, :fixed) do
    [current_field | other_fields] = fields_list

    field_size = @fields_descriptors[current_field][:length]
    <<current_hex::binary-size(field_size), rest_hex::bitstring>> = hex

    {:ok, field_value} =
      parse_field_alphanumeric(
        @fields_descriptors[current_field][:length_mode],
        @fields_descriptors[current_field][:length],
        current_hex
      )

    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(
      other_fields,
      rest_hex,
      result_map,
      @fields_descriptors[List.first(other_fields)][:content_type],
      @fields_descriptors[List.first(other_fields)][:length_mode]
    )
  end

  def parse_fields(fields_list, hex, result_map, :alphanumeric, :variable_lll) do
    [current_field | other_fields] = fields_list

    <<size::binary-size(2), size_rest_hex::bitstring>> = hex

    padded_size = Bcd.decode(<<0, 0>> <> size)
    <<field_hex::binary-size(padded_size), rest_hex::bitstring>> = size_rest_hex

    {:ok, field_value} =
      parse_field_alphanumeric(
        @fields_descriptors[current_field][:length_mode],
        padded_size,
        field_hex
      )

    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(
      other_fields,
      rest_hex,
      result_map,
      @fields_descriptors[List.first(other_fields)][:content_type],
      @fields_descriptors[List.first(other_fields)][:length_mode]
    )
  end

  def parse_fields(fields_list, hex, result_map, :alphanumeric, :variable_ll) do
    [current_field | other_fields] = fields_list

    <<size::binary-size(1), size_rest_hex::bitstring>> = hex

    padded_size = Bcd.decode(<<0, 0, 0>> <> size)
    <<field_hex::binary-size(padded_size), rest_hex::bitstring>> = size_rest_hex

    {:ok, field_value} =
      parse_field_alphanumeric(
        @fields_descriptors[current_field][:length_mode],
        padded_size,
        field_hex
      )

    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(
      other_fields,
      rest_hex,
      result_map,
      @fields_descriptors[List.first(other_fields)][:content_type],
      @fields_descriptors[List.first(other_fields)][:length_mode]
    )
  end

  def parse_bitmap(bitmap_hex) do
    parse_bitmap(bitmap_hex, 1)
  end

  # If the next bit is 1, count it and recurse
  def parse_bitmap(<<1::1, rest::bitstring>>, current_field),
    do: [current_field] ++ parse_bitmap(rest, current_field + 1)

  # If the next bit is 0, don't count it and recurse
  def parse_bitmap(<<0::1, rest::bitstring>>, current_field),
    do: parse_bitmap(rest, current_field + 1)

  # Base case: if bits have run out, stop
  def parse_bitmap(<<>>, _), do: []

  def parse_field_alphanumeric(:fixed, length, hex) when byte_size(hex) > length do
    {:error, :too_long,
     "Field too long: current length (#{byte_size(hex)}) is greater than the maximum length of: #{length}"}
  end

  def parse_field_alphanumeric(:fixed, length, hex) when byte_size(hex) < length do
    {:error, :too_short,
     "Field too short: current length (#{byte_size(hex)}) is less than the minimum length of: #{length}"}
  end

  def parse_field_alphanumeric(_, _, hex) do
    {:ok, Enum.join(for <<c::utf8 <- hex>>, do: <<c::utf8>>)}
  end

  def parse_field_numeric(:fixed, length, hex) do
    parsed_value = parse_field_numeric(hex)

    right_aligned_value =
      String.slice(
        parsed_value,
        (String.length(parsed_value) - length)..String.length(parsed_value)
      )

    {:ok, right_aligned_value}
  end

  def parse_field_numeric(<<digit::4, rest::bitstring>>),
    do: Integer.to_string(digit) <> parse_field_numeric(rest)

  # Base case: if bits have run out, stop
  def parse_field_numeric(<<>>), do: ""

  def parse_field_track2(_, length, hex) do
    parsed_value = parse_field_track2(hex)

    right_aligned_value =
      String.slice(
        parsed_value,
        (String.length(parsed_value) - length)..String.length(parsed_value)
      )

    {:ok, right_aligned_value}
  end

  def parse_field_track2(<<digit::4, rest::bitstring>>) do
    case digit do
      0xD -> "=" <> parse_field_track2(rest)
      0xF -> parse_field_track2(rest)
      _ -> Integer.to_string(digit) <> parse_field_track2(rest)
    end
  end

  # Base case: if bits have run out, stop
  def parse_field_track2(<<>>), do: ""

  def parse_field_binary(:fixed, _, hex) do
    {:ok, Base.encode16(hex)}
  end
end
