defmodule BackendBattle.MessageHelper do
  # Macro for validating a non empty string length
  defmacro validate_string_length(name, max_length) do
    quote do
      def unquote(name)(nil), do: :unprocessable
      def unquote(name)(n) when not is_binary(n), do: :bad_request

      def unquote(name)(<<_::binary-size(1), _::bitstring>> = str) do
        if String.length(str) <= unquote(max_length) do
          :ok
        else
          :unprocessable
        end
      end

      def unquote(name)(_), do: :unprocessable
    end
  end
end
