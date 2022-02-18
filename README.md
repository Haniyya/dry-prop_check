# Dry::PropCheck

Property tests using `Dry::Structs`. This library extends the `prop_check` by
adding a `Dry::Struct` compiler that creates a generator based on the provided
struct.

**Note:** Very much WIP. There are still lots of incompatibilities and deeply
nested structs are **very slow** to generate. But feel free to try it out.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-prop_check'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dry-prop_check

## Usage

In your test you can compile a `Dry::Type` (or `Dry::Schema` or `Dry::Struct`)
to a generator usable by `prop_check`.

```rb
class Person < Dry::Struct
  attribute :given_name, Type::String
  attribute :family_name, Type::String
  attribute :age, Types::Integer.optional

  def full_name
    "#{given_name} #{family_name}"
  end
end

# And in your test

let(:compiler) { Dry::PropCheck::Compiler.new }
let(:generator) { compiler.visit(Person.to_ast) }

describe '#full_name' do
  it 'always includes given_name and family_name' do
    PropCheck.forall(generator) do |person|
      expect(person.full_name).to match(person.given_name)
      expect(person.full_name).to match(person.family_name)
    end
  end
end
```

## Restrictions

This library tries to compile fitting type-generators for all built-in
`Dry::Type` s. But some types will be very hard to fulfill: arbitrary filters or
regex-restrictions may significantly hamper generation.

## Maybe-Future-Features

* Override generators for specific attributes. This may help with stuff like
  regex-restrictions.
* Improve performance with deeply nested structs. The naive recursive compiler
  creates very inefficient generators. While this is not important for small and
  flat structs, deeply nested hierarchies cause a massive performance hit.
* Relations between structs. A la
  [specmonstah](https://github.com/reifyhealth/specmonstah).
* Maybe get away from `prop_check` since it seems abandoned.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Haniyya/dry-prop_check. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Haniyya/dry-prop_check/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the Dry::PropCheck project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Haniyya/dry-prop_check/blob/master/CODE_OF_CONDUCT.md).
