defmodule IntellijElixir.QuoterTest do
  use ExUnit.Case

  @code "Alias.function positional, key: value"
  @quoted Code.string_to_quoted(@code)

  # Raises on every supported release, unlike the constructs whose rejection moved from a raise to an
  # error tuple across versions.
  @raising <<0xFF>>

  test "responds to GenServer.call" do
    assert @quoted == GenServer.call(IntellijElixir.Quoter, @code)
  end

  test "responds to raw send of GenServer.call" do
    ref = make_ref()
    send(IntellijElixir.Quoter, {:"$gen_call", {self(), ref}, @code})

    assert_receive {^ref, @quoted}
  end

  test "answers a raise with a term" do
    assert {:raise, UnicodeConversionError, message} =
             GenServer.call(IntellijElixir.Quoter, @raising)

    assert is_binary(message)
  end

  test "survives a raise" do
    pid = Process.whereis(IntellijElixir.Quoter)
    GenServer.call(IntellijElixir.Quoter, @raising)

    assert Process.whereis(IntellijElixir.Quoter) == pid
    assert @quoted == GenServer.call(IntellijElixir.Quoter, @code)
  end
end
