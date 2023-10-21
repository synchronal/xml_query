defmodule XmlQuery.Attribute do
  import Record
  require XmlQuery

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
        name: XmlQuery.xmlAttribute(attribute, :name),
        value: XmlQuery.xmlAttribute(attribute, :value),
        shadows: attribute
      )
end
