defmodule ISO8583 do
  @moduledoc """
  Documentation for `ISO8583`.
  """
  require Logger


  def parse_message( fields_descriptors, message_hex) do
    << _::binary-size(7), mti_rest :: bitstring >> = message_hex
    << _::binary-size(2), header_rest :: bitstring >> = mti_rest
    << bitmap_hex::binary-size(8), bitmap_rest :: bitstring >> = header_rest
    bitmap = parse_bitmap(bitmap_hex)

    parse_fields(fields_descriptors, bitmap, bitmap_rest, %{},
    fields_descriptors[List.first(bitmap)][:content_type],
    fields_descriptors[List.first(bitmap)][:length_mode]
    )
  end


  # Base case: if bits have run out, stop
  def parse_fields(_, [], _, result_map, _, _), do: result_map

  def parse_fields(fields_descriptors, fields_list, hex, result_map, :numeric, :fixed) do
    [current_field | other_fields] = fields_list
    field_size = ceil(fields_descriptors[current_field][:length] / 2)
    << current_hex :: binary-size(field_size), rest_hex :: bitstring >> = hex

    {:ok, field_value} = parse_field_numeric(fields_descriptors[current_field][:length_mode],
    fields_descriptors[current_field][:length],
    current_hex )
    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(fields_descriptors, other_fields, rest_hex, result_map,
    fields_descriptors[List.first(other_fields)][:content_type],
    fields_descriptors[List.first(other_fields)][:length_mode])
  end

  def parse_fields(fields_descriptors, fields_list, hex, result_map, :alphanumeric, :fixed) do
    [current_field | other_fields] = fields_list
    field_size = fields_descriptors[current_field][:length]
    << current_hex :: binary-size(field_size), rest_hex :: bitstring >> = hex

    {:ok, field_value} = parse_field_alphanumeric(fields_descriptors[current_field][:length_mode],
    fields_descriptors[current_field][:length],
    current_hex )
    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(fields_descriptors, other_fields, rest_hex, result_map,
    fields_descriptors[List.first(other_fields)][:content_type],
    fields_descriptors[List.first(other_fields)][:length_mode])
  end

  def parse_fields(fields_descriptors, fields_list, hex, result_map, :alphanumeric, :variable_lll) do
    [current_field | other_fields] = fields_list
    << size :: binary-size(2), size_rest_hex :: bitstring >> = hex

    padded_size = Bcd.decode(<<0,0>> <> size)
    << field_hex :: binary-size(padded_size), rest_hex :: bitstring >> = size_rest_hex

    {:ok, field_value} = parse_field_alphanumeric(fields_descriptors[current_field][:length_mode], padded_size, field_hex )
    result_map = Map.put(result_map, current_field, field_value)

    parse_fields(fields_descriptors, other_fields, rest_hex, result_map,
    fields_descriptors[List.first(other_fields)][:content_type],
    fields_descriptors[List.first(other_fields)][:length_mode])
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

  def parse_field_alphanumeric( _, _, hex ) do
    {:ok, Enum.join(for <<c::utf8 <- hex>>, do: <<c::utf8>>)}
  end

  def parse_field_numeric( :fixed, length, hex ) do
    parsed_value = parse_field_numeric(hex)
    right_aligned_value = String.slice(parsed_value, (String.length(parsed_value) - length)..String.length(parsed_value) )
    {:ok, right_aligned_value}
  end

  def parse_field_numeric(<< digit :: 4, rest :: bitstring >>), do: Integer.to_string(digit) <> parse_field_numeric(rest)

  # Base case: if bits have run out, stop
  def parse_field_numeric(<< >>), do: ""


  def parse_field_binary( :fixed, _, hex ) do
    {:ok, Base.encode16(hex)}
  end
end
