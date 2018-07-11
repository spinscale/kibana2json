# kibana2json

A simple helper to reformat JSON pasted from Kibana that uses the famoues triple ticks (`"""`) and thus has multi line scripts and broken search queries back to valid JSON.

This helps to run `jq` or JSON formatting tools on the command line against those JSON files.

The tool checks for beginning and end of triple double quotes, escapes all double quotes within and also condenses everything down to one line (this might result in invalid painless scripts, but keeps valid JSON).

## Installation

First, make sure you have crystal installed. See the [crystal install docs](https://crystal-lang.org/docs/installation/).

Second, run `crystal build --release src/kibana2json.cr` and use the `kibana2json` binary created in the directory.

## Usage

`kibana2json` reads from stdin only. The only options available are `--version` and `--help`.

I usually use it like this

```
# echo '{ "foo" : """what"ever""" }' | ./kibana2json | python -mjson.tool
```

or with JQ

```
echo '{ "foo" : """what"ever""" }' | ./kibana2json | jq ".foo"
```

## Development

Most likely you found a bug in this pretty raw tool.
In that case please write a failing test in `spec/json_parser_spec.cr`, fix it and open a pull request. Alternatively open an issue with a sample snippet of JSON and I'll take a look at it when possible.

You can run the tests locally by running `crystal spec`. 

## Contributing

1. Fork it (<https://github.com/your-github-user/kibana2json/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [spinscale](https://github.com/spinscale) Alexander Reelsen - creator, maintainer
