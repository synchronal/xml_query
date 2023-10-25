defmodule XmlQuery.Attribute do
  # @related [tests](test/xml_query/attribute_test.exs)
  import Record
  require XmlQuery.Xmerl

  @type t() :: %__MODULE__{}

  @keys ~w[
    name
    value
    shadows
  ]a

  @enforce_keys @keys
  defstruct @keys

  @spec new(XmlQuery.xml_attribute()) :: t()
  def new(attribute) when is_record(attribute, :xmlAttribute),
    do:
      __struct__(
        name: XmlQuery.Xmerl.xmlAttribute(attribute, :name),
        value: XmlQuery.Xmerl.xmlAttribute(attribute, :value),
        shadows: attribute
      )

  def pretty(attr) when is_struct(attr, __MODULE__),
    do: to_string(attr)

  # # #

  defimpl String.Chars do
    def to_string(attr) do
      attr.shadows
      |> XmlQuery.Xmerl.xmlAttribute(:value)
      |> Kernel.to_string()
    end
  end
end
