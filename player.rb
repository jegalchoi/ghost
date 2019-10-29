
class Player
  attr_accessor :name, :guess, :losses

  def initialize(name)
    @name = name
    @losses = 0
  end

  def guess
    puts "#{name}, guess a letter."
    guess = gets.chomp
  end
end
