defmodule XmlQuery.Attribute do
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
end
