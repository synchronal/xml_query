# XmlQuery

A concise API for querying XML. There are just 5 main functions:
`all/2`, `find/2` and `find!/2` for finding things, plus `attr/2` and `text/1` for extracting
information. There are also a handful of other useful functions, referenced below and described in detail in
the [module docs](https://hexdocs.pm/xml_query/XmlQuery.html). XML parsing is handled by Erlang/OTP’s built-in
[xmerl](https://www.erlang.org/doc/man/xmerl) library.

The input can be:

* A string of XML.
* An `Xmerl.xml_attribute()`, `Xmerl.xml_document()`, `Xmerl.xml_element()`, or `Xmerl.xml_text()`.
* An `XmlQuery.Element` struct.
* Anything that implements the `String.Chars` protocol.

We created a related library called [HtmlQuery](https://hexdocs.pm/html_query/readme.html) which has the same API but
is used for querying HTML.

This library is MIT licensed and is part of a growing number of Elixir open source libraries published at
[github.com/synchronal](https://github.com/synchronal#elixir).

## Installation

```elixir
def deps do
  [
    {:xml_query, "~> 0.2.1"}
  ]
end
```

## Usage

Detailed docs are in the [XmlQuery module docs](https://hexdocs.pm/xml_query/XmlQuery.html); a quick usage
overview follows.

We typically alias `XmlQuery` to `Xq`:

```elixir
alias XmlQuery, as: Xq
```

The rest of these examples use the following XML:

```elixir
xml = """
<?xml version="1.0"?>
<family>
  <child age="12" name="Alice" />
  <child age="9" name="Billy">
    <toys>
      <toy name="Voltron" part-number="voltr-123">
        <limb>Leg</limb>
        <animal>Lion</animal>
        <color>Blue</color>
      </toy>
    </toys>
  </child>
</family>
"""
```

### Querying

Query functions use XPath selector strings for finding nodes. The
[Devhints XPath cheatsheet](https://devhints.io/xpath) is a helpful XPath reference.

```elixir
Xq.find!(xml, "//toy/animal")
```

The result of a query is an `XmlQuery.Element` struct, a list of `XmlQuery.Element` structs, an `XmlQuery.Attribute`
struct, or an `XmlQuery.Text` struct. All of these structs implement `String.Chars` so you can convert them to strings
with `to_string/1`:

```elixir
Xq.find!(xml, "//toy/animal") |> to_string() # returns "<animal>Lion</animal>"
```

### Finding

```elixir
Xq.all(xml, "//child") # returns a list of all the <child> elements
Xq.find(xml, ~s|//child[@name="Alice"]|) # returns the <child> with name "Alice"
Xq.find!(xml, ~s|//child[@name="foo"]|) # raises because no such element exists
```

See the [module docs](https://hexdocs.pm/xml_query/XmlQuery.html) for more details.

### Extracting

`text/1` is the simplest extraction function:

```elixir
xml |> Xq.find!("//toy") |> Xq.text() # returns "Leg Lion Blue"
```

`attr/2` returns the value of an attribute:

```elixir
xml |> Xq.find!(~s|//toy[@part-number="voltr-123"]|) |> Xq.attr("name") # returns "Voltron"
```

To extract data from multiple XML nodes, we found that it is clearer to compose multiple functions rather than to
have a more complicated API:

```elixir
xml |> Xq.all("//toy/*") |> Enum.map(&Xq.text/1) # returns ["Leg", "Lion", "Blue"]
xml |> Xq.all("//child") |> Enum.map(&Xq.attr(&1, "age")) # returns ["12", "9"]
```

See the [module docs](https://hexdocs.pm/xml_query/XmlQuery.html) for more details.

### Parsing

`parse/1` parses an XML document and returns an `XmlQuery.Element` struct. It is rarely needed since all the XmlQuery
functions will parse XML if needed. See the [module docs](https://hexdocs.pm/xml_query/XmlQuery.html) for more details.

### Utilities

`pretty/1` formats XML in a human-friendly format. See the [module docs](https://hexdocs.pm/xml_query/XmlQuery.html)
for more details.

## Development

```shell
bin/dev/doctor
bin/dev/update
bin/dev/audit
bin/dev/shipit
```

## References

- https://gist.github.com/sasa1977/5967224
- https://medium.com/erlang-battleground/the-hidden-xml-simplifier-a5f66e10c928

