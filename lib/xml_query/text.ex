defmodule XmlQuery.Text do
  # @related [tests](test/xml_query/text_test.exs)
  import Record
  require XmlQuery.Xmerl

  @type t() :: %__MODULE__{}

  @keys ~w[
    contents
    shadows
  ]a

  @enforce_keys @keys
  defstruct @keys

  @spec new(XmlQuery.xml_text()) :: t()
  def new(text) when is_record(text, :xmlText),
    do:
      __struct__(
        contents: XmlQuery.Xmerl.xmlText(text, :value),
        shadows: text
      )

  @doc false
  def to_string(node) when is_record(node, :xmlText),
    do: node |> XmlQuery.Xmerl.xmlText(:value) |> Kernel.to_string()

  defimpl String.Chars do
    def to_string(text) do
      text.shadows
      |> XmlQuery.Xmerl.xmlText(:value)
      |> Kernel.to_string()
    end
  end
end
