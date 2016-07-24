require 'spec_helper'
require 'frest/core'

require 'ostruct'


class Hash
  alias_method :del, :delete
end

describe Frest::Composers do
  it 'has a version number' do
    expect(Frest::Composers::VERSION).not_to be nil
  end

  it 'can compose two namespaces' do
    ns1 = {
        'a' => 1,
        'b' => 2
    }

    def ns1.method_missing _
      Frest::Core::NotFound
    end

    ns2 = {
      'b' => :b,
      'c' => 2
    }

    def ns2.method_missing _
      Frest::Core::NotFound
    end

    [ns1, ns2].each do |n|
      def n.get(id:)
        self[id] || Frest::Core::NotFound
      end

      def n.put(id:, content:)
        self[id] = content
      end

      def n.delete(id:)
        self.del(id){|_| Frest::Core::NotFound}
      end
    end


    composed = Frest::Composers.priority(endpoints: [ns1, ns2])

    expect(composed.get id: 'a').to eq(1)
    expect(composed.get id: 'b').to eq(2)
    expect(composed.get id: 'c').to eq(2)
    expect(composed.get id: 'foo').to eq (Frest::Core::NotFound)

    composed.put(
        id: 'foo',
        content: :this_is_foo
    )

    expect(composed.get(
         id: 'foo'
    )).to eq(:this_is_foo)

    composed.delete(
          id: :c
    )

    expect(composed.get(
         id: :c
    )).to eq(Frest::Core::NotFound)
  end
end
