# XmlQuery

Some simple XML query functions. Delegates much of its work to `:xmerl`, but provides
an API similar to `HtmlQuery`.

```elixir
iex> alias XmlQuery, to: Xq

iex> xml = """
<?xml version="1.0"?>
<family>
  <child age="12" name="Alice" />
  <child age="9" name="Billy">
    <toys>
      <toy name="Voltron">
        <limb>Leg</limb>
        <animal>Lion</animal>
        <color>Blue</color>
      </toy>
    </toys>
  </child>
</family>
"""

iex> xml |> Xq.all("//child") |> Enum.map(&Xq.attr(&1, "age"))
["12", "9"]

iex> xml |> Xq.find!("//toy") |> Xq.text()
"Leg Lion Blue"

iex> xml |> Xq.find!("//toy/animal") |> Xq.text()
"Lion"
```

## API Docs

See the documentation for the main `XmlQuery` module for details and more examples:

<https://hexdocs.pm/xml_query/XmlQuery.html>

## Installation

```elixir
def deps do
  [
    {:xml_query, "~> 0.1.0"}
  ]
end
```

## Development

```shell
brew bundle

bin/dev/doctor
bin/dev/update
bin/dev/audit
bin/dev/shipit
```

## References

- https://gist.github.com/sasa1977/5967224
- https://medium.com/erlang-battleground/the-hidden-xml-simplifier-a5f66e10c928

