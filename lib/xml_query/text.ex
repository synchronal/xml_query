defmodule XmlQuery.Text do
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

  def to_string(node) when is_record(node, :xmlText),
    do: node |> XmlQuery.Xmerl.xmlText(:value) |> Kernel.to_string()
end
