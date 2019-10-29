require 'byebug'
require 'pry'
require 'set'

require_relative "player"

#puts 'START'

class Game
  attr_accessor :players, :current_player, :number_of_players, :fragment, :game_over, :losses, :scoreboard, :standings

  DICTIONARY = IO.readlines('dictionary.txt').map { |word| word.chomp }.to_set

  def initialize
    @players = []
    @number_of_players = gets.chomp.to_i
    @current_player = ""
    @fragment = ""
    @scoreboard = self.scoreboard
    @game_over = false
    puts "\nEnter each player's name (Enter AI if you'd like to play against the AI):"
    @number_of_players.times { self.create_player }
  end

  def create_player
    name = gets.chomp
    
    if @players.any? { |player| player.name == name }
      puts 'That name has already been taken. Please enter another name.'
      self.create_player
    else
      new_player = Player.new(name)  
      @players << new_player
      print "#{name} is now playing."
      puts "\n\n"
    end
  end

  def play_round
      turn = 1

      while self.game_over? == false
        self.turn_sign(turn)
        self.standings

        @players.each_with_index do |player, idx|
          take_turn(idx) unless @players[idx].losses == 5

          if self.in_dictionary?
            puts "The word is in the dictionary. #{@current_player.name}, you just earned a letter!"
            break
          end

          if self.invalid_guess?
            puts "Invalid letter. #{@current_player.name}, you just earned a letter!"
            break
          end

          break if self.game_over? == true
        end

        turn += 1
      end

      self.winner
  end

  def take_turn(idx)
    @current_player = players[idx]
    puts "\nCurrent Player: " + @current_player.name
    if @current_player.name == "AI"
      @fragment << ai_guess
    else
      @fragment << players[idx].guess
    end
    puts "\nFRAGMENT: " + @fragment
  end

  def ai_guess
    self.available_moves
    
    if available_moves.empty?  
      alphabet.sample
    else
      available_moves.sort_by { |letter, ratio| ratio }.reverse.each_with_index do |letter, idx|
        potential_fragment = @fragment + letter[0]
        return letter[0] if Game::DICTIONARY.select { |word| word.match(/^#{potential_fragment}.*/) } != [] && !Game::DICTIONARY.include?(potential_fragment)
      end
      alphabet.sample
    end
  end

  def available_moves
    alphabet = ("a".."z").to_a
    available_moves = {}
    
    alphabet.each do |letter|
      potential_fragment = @fragment + letter
      count_winning_words = 0
      count_losing_words = 0
      
      Game::DICTIONARY.select { |word| word.match(/^#{potential_fragment}.*/) }.each do |possible_word|  
        count_winning_words += 1 if (possible_word.length - @fragment.length) % (@number_of_players + 1) != 0
        count_losing_words += 1 if (possible_word.length - @fragment.length) % (@number_of_players + 1) == 0  
      end
      
      w_l_ratio = count_winning_words / (count_losing_words * 1.0)
      available_moves[letter] = w_l_ratio.round(5) unless w_l_ratio.nan?
    end

    available_moves
  end

  def invalid_guess?
    if Game::DICTIONARY.select { |word| word.match(/^#{@fragment}.*/) } == []
      @current_player.losses += 1 unless @current_player.losses == 5
      @fragment = ""
      return true
    else
      return false
    end
  end

  def in_dictionary?
    if Game::DICTIONARY.include?(@fragment)
      @current_player.losses += 1 unless @current_player.losses == 5
      @fragment = ""
      return true
    else
      return false
    end
  end

  def lose?
    if self.players.any? { |hash| hash.losses == 5 }
      return true
    else
      return false
    end
  end

  def game_over?
    if self.players.select { |hash| hash.losses == 5 }.length == @players.length - 1
      return true
    else
      return false
    end
  end

  def winner
    self.standings
    winner = @players.select { |hash| hash.losses != 5 }
    puts winner[0].name + " is the winner!"
    puts "\nThanks for playing!"
    return true
  end

  def standings
    puts "\nFRAGMENT: " + @fragment
    unless self.scoreboard == []
      puts "\nSCOREBOARD:"
      puts self.scoreboard
    end
    puts "\n\n"
  end

  def scoreboard
    arr = []

    self.players.each do |k|
      if k.losses == 1
        arr << k.name + " - G"
      elsif k.losses == 2
        arr << k.name + " - GH"
      elsif k.losses == 3
        arr << k.name + " - GHO"
      elsif k.losses == 4
        arr << k.name + " - GHOS"
      elsif k.losses == 5
        arr << k.name + " - GHOST - ELIMINATED!"
      end
    end

    arr
  end

  def turn_sign(turn)
    puts "\n"
    50.times {print "*"}
    puts "\nTurn #{turn}"
    50.times {print "*"}
  end

  def current_player(num)
    @players[num]
  end
end

#binding.pry

#puts 'END'
