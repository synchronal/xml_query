defmodule Test.SimpleCase do
  @moduledoc """
  The simplest test case template.
  """

  use ExUnit.CaseTemplate
  require XmlQuery

  using do
    quote do
      import Moar.Assertions
      import Moar.Sugar
      import Test.SimpleCase
    end
  end

  def xml_attribute(name, opts \\ []),
    do:
      XmlQuery.xmlAttribute(
        name: name,
        parents: Keyword.get(opts, :parents, []),
        pos: Keyword.get(opts, :pos, 1),
        value: Keyword.fetch!(opts, :value),
        normalized: false
      )

  def xml_element(name, opts \\ []),
    do:
      XmlQuery.xmlElement(
        name: name,
        content: Keyword.get(opts, :children, []),
        expanded_name: name,
        parents: Keyword.get(opts, :parents, []),
        pos: Keyword.get(opts, :pos, 1),
        attributes: Keyword.get(opts, :attrs, []),
        xmlbase: ~c"/"
      )

  def xml_text(contents, opts) when is_binary(contents),
    do: xml_text(String.to_charlist(contents), opts)

  def xml_text(contents, opts),
    do:
      XmlQuery.xmlText(
        parents: Keyword.get(opts, :parents, []),
        pos: Keyword.get(opts, :pos, 1),
        value: contents
      )
end
