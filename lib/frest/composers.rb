require "frest/composers/version"
require 'frest/core'

module Frest
  class ComposersClass
    attr_accessor :getters, :putters, :deleters

    def initialize(*stores)
      @getters  = []
      @putters  = []
      @deleters = []

      stores.each do |store|
        getters << store if store.respond_to? :get
        putters << store if store.respond_to? :put
        deleters << store if store.respond_to? :delete
      end
    end

    def get(
        **c
    )
      getters.each do |g|
        result = g.get(**c)
        return result if result != Frest::Core::NotFound
      end

      Frest::Core::NotFound
    end

    def put(
        **c
    )
      putters.each do |s|
        return unless s.put(**c) == Frest::Core::NotSet
      end

      Frest::Core::NotSet
    end

    def delete(
        **c
    )
      deleters.each do |s|
        return unless s.delete(**c) == Frest::Core::NotDeleted
      end

      Frest::Core::NotDeleted
    end
  end

  module Composers
    module_function def priority(
        endpoints:
    )
      ComposersClass.new(*endpoints)
    end
  end
end
