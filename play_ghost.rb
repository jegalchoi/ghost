require_relative "ghost"

puts "\nWelcome to Ghost.\n\n"
puts "Enter the number of Players:"
ghost = Game.new


until ghost.game_over?
  ghost.play_round
end
