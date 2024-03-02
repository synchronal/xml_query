defmodule Test.Etc.TestNode do
  @moduledoc """
  A struct that implements `String.Chars`, for use in `XmlQueryTest`.

  This needs to be in its own `.ex` file rather than defined inside a test,
  because `defimpl` doesn't work in `.exs` files (see https://hexdocs.pm/elixir/Protocol.html#module-consolidation)
  """
  defstruct [:contents]

  defimpl String.Chars do
    def to_string(test_node), do: "<test-node>#{test_node.contents}</test-node>"
  end
end
