# ![gloom](https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/44.png)Gloomex

<b>G</b>uava like b<b>loom</b> filter library for <b>e</b>li<b>x</b>ir.

Supports murmur_x64_128 and uses a bit array implemented with [:atomics](https://erlang.org/doc/man/atomics.html).

It has the same false-positives as present in the bloom filter from the Guava library.

## Installation

```elixir
def deps do
  [
    {:gloomex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
file = "top_passwords.txt"
false_positive_ratio = 0.01
# creates bloom filter from file
bloom_filter = Gloomex.plain_from_file(file, false_positive_ratio)
# returns true if present or false positive
Gloomex.might_contain?(bloom_filter, "123456789")
```

You can also create the bloom filter manually, but beware that the put! is a mutable function for efficiency reasons.
```elixir
file = "top_passwords.txt"

expected_insertions = file
|> File.stream!()
|> Enum.count()

false_positive_ratio = 0.01

# creates bloom filter from file
bloom_filter = Gloomex.plain(expected_insertions, false_positive_ratio)

file
|> File.stream!()
|> Enum.each(fn word ->
  Gloomex.put!(bloom_filter, String.trim(word))
end)

# returns true if present or false positive
Gloomex.might_contain?(bloom_filter, "123456789")
```
