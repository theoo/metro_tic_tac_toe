module Ai

  Dir["./ai/*.rb"].each {|file| require file }

  def self.init(name)
    @scheme = Object.const_get("Ai::#{name}").new
  end

end

