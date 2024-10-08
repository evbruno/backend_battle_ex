defmodule BackendBattle.MessageTest do
  use ExUnit.Case

  import BackendBattle.Message
  import String, only: [duplicate: 2]

  @base_paylod %{"apelido" => "nickname", "nome" => "name", "nascimento" => "1981-12-26"}

  test "valid_payload?/1" do
    assert valid_payload?(@base_paylod) == :ok

    assert valid_payload?(add("stack", ["elixir"])) == :ok

    assert valid_payload?(add("stack", ["elixir", 42])) == :bad_request
    assert valid_payload?(add("stack", [duplicate("á", 33)])) == :unprocessable

    assert valid_payload?(add("apelido", 42)) == :bad_request
    assert valid_payload?(remove("apelido")) == :bad_request
    assert valid_payload?(add("apelido", nil)) == :unprocessable
    assert valid_payload?(add("apelido", duplicate("á", 33))) == :unprocessable

    assert valid_payload?(add("nome", 42)) == :bad_request
    assert valid_payload?(remove("nome")) == :bad_request
    assert valid_payload?(add("nome", nil)) == :unprocessable
    assert valid_payload?(add("nome", duplicate("á", 101))) == :unprocessable

    assert valid_payload?(add("nascimento", "1981/12/26")) == :unprocessable
    assert valid_payload?(add("nascimento", "xxxx-xx-xx")) == :unprocessable
    assert valid_payload?(add("nascimento", nil)) == :bad_request
    assert valid_payload?(remove("nascimento")) == :bad_request
  end

  defp add(k, v), do: Map.put(@base_paylod, k, v)
  defp remove(k), do: Map.delete(@base_paylod, k)

  test "valid_nickname?/1" do
    assert valid_nickname?(duplicate("a", 1)) == :ok
    assert valid_nickname?(duplicate("a", 32)) == :ok
    assert valid_nickname?(duplicate("ç", 32)) == :ok

    assert valid_nickname?("") == :unprocessable
    assert valid_nickname?(nil) == :unprocessable
    assert valid_nickname?(duplicate("a", 33)) == :unprocessable

    assert valid_nickname?(42) == :bad_request
  end

  test "valid_name?/1" do
    assert valid_name?(duplicate("a", 1)) == :ok
    assert valid_name?(duplicate("a", 100)) == :ok
    assert valid_name?(duplicate("ã", 100)) == :ok

    assert valid_name?(nil) == :unprocessable
    assert valid_name?("") == :unprocessable
    assert valid_name?(duplicate("a", 101)) == :unprocessable

    assert valid_name?(42) == :bad_request
  end

  test "valid_bday?/1" do
    assert valid_bday?("2000-01-01") == :ok
    assert valid_bday?("0001-01-01") == :ok
    assert valid_bday?("9999-13-32") == :ok

    assert valid_bday?("9999/13/32") == :unprocessable
    assert valid_bday?("9999-13-2") == :unprocessable
    assert valid_bday?("9999-1-22") == :unprocessable
    assert valid_bday?("999-11-22") == :unprocessable
    assert valid_bday?("99991122") == :unprocessable

    assert valid_bday?(1981) == :bad_request
    assert valid_bday?(nil) == :bad_request
  end

  test "valid_stacks?/1" do
    assert valid_stacks?(nil) == :ok
    assert valid_stacks?([]) == :ok
    assert valid_stacks?(["foo"]) == :ok
    assert valid_stacks?(["foo", "bar"]) == :ok
    assert valid_stacks?([duplicate("a", 32)]) == :ok
    assert valid_stacks?(["abc", duplicate("ç", 32)]) == :ok

    assert valid_stacks?(["foo", 42]) == :bad_request
    assert valid_stacks?([42]) == :bad_request

    assert valid_stacks?(["foo", duplicate("a", 33)]) == :unprocessable
  end
end
