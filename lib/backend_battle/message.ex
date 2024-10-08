defmodule BackendBattle.Message do
  @year_regex ~r/^\d{4}$/
  @dm_regex ~r/^\d{2}$/

  import BackendBattle.MessageHelper

  def valid_payload?(%{"apelido" => nn, "nome" => n, "nascimento" => bd, "stack" => s}),
    do: valid_fields?(nn, n, bd, s)

  def valid_payload?(%{"apelido" => nn, "nome" => n, "nascimento" => bd}),
    do: valid_fields?(nn, n, bd)

  def valid_payload?(_), do: :bad_request

  defp valid_fields?(nick, name, bday, stack \\ []) do
    [nick, name, bday, stack]
    |> Enum.reduce_while(:ok, fn field, _acc ->
      case field do
        ^nick -> valid_nickname?(nick) |> halt_or_continue()
        ^name -> valid_name?(name) |> halt_or_continue()
        ^bday -> valid_bday?(bday) |> halt_or_continue()
        ^stack -> valid_stacks?(stack) |> halt_or_continue()
      end
    end)
  end

  defp halt_or_continue(:ok), do: {:cont, :ok}
  defp halt_or_continue(err), do: {:halt, err}

  # macro will generate a valid_nickname/1, that requires a non-empty string with at most 32 characters.
  validate_string_length(:valid_nickname?, 32)

  # macro will generate a valid_nickname/1, that requires a non-empty string with at most 100 characters.
  validate_string_length(:valid_name?, 100)

  # Required, string for the date in the format YYYY-MM-DD (year, month, day).
  @spec valid_bday?(any()) :: :bad_request | :ok | :unprocessable
  def valid_bday?(<<y::binary-size(4), "-", m::binary-size(2), "-", d::binary-size(2)>>) do
    if Regex.match?(@year_regex, y) and Regex.match?(@dm_regex, m) and Regex.match?(@dm_regex, d) do
      :ok
    else
      :unprocessable
    end
  end

  def valid_bday?(n) when is_bitstring(n), do: :unprocessable
  def valid_bday?(_), do: :bad_request

  validate_string_length(:valid_stack?, 32)

  def valid_stacks?(nil), do: :ok
  def valid_stacks?([]), do: :ok

  def valid_stacks?([<<_::binary-size(1), _::bitstring>> = n | rest]) do
    if String.length(n) > 32 do
      :unprocessable
    else
      valid_stacks?(rest)
    end
  end

  def valid_stacks?(_), do: :bad_request
end
