defmodule IntellijElixir.Quoter do
  @moduledoc """
  `Code.string_to_quoted/1` server
  """
  use GenServer

  # Types

  @type t :: []
  @type line :: non_neg_integer
  @type error :: any
  @type token :: binary
  @type raised :: {:raise, module | :throw | :exit, binary}

  @doc """
  Starts the Quoter GenServer.

  ## Options

    * `:name` - registers the process under the given name

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    {name, _opts} = Keyword.pop(opts, :name)
    server_opts = if name, do: [name: name], else: []
    GenServer.start_link(__MODULE__, [], server_opts)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  @spec handle_call(String.t(), GenServer.from(), t) ::
          {:reply, {:ok, Macro.t()} | {:error, {line, error, token}} | raised, t}
  def handle_call(code, _from, state) do
    {:reply, quote_code(code), state}
  end

  # Older releases reject some constructs by raising rather than by returning `{:error, _}`. Answering
  # with a term keeps the server alive, so the caller sees the rejection and later calls are unaffected.
  @spec quote_code(String.t()) :: {:ok, Macro.t()} | {:error, {line, error, token}} | raised
  defp quote_code(code) do
    Code.string_to_quoted(code)
  rescue
    exception -> {:raise, exception.__struct__, Exception.message(exception)}
  catch
    :throw, thrown -> {:raise, :throw, inspect(thrown)}
    :exit, reason -> {:raise, :exit, inspect(reason)}
  end
end
