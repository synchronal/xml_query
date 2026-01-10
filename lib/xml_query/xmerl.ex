defmodule XmlQuery.Xmerl do
  require Record

  Record.defrecord(:xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlComment, Record.extract(:xmlComment, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlDocument, Record.extract(:xmlDocument, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @type xml_attribute() :: record(:xmlAttribute)
  @type xml_comment() :: record(:xmlComment)
  @type xml_document() :: record(:xmlDocument)
  @type xml_element() :: record(:xmlElement)
  @type xml_text() :: record(:xmlText)
end
