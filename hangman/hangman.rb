require 'yaml'

class Hangman
  
  Max_guesses = 5
  
  attr_accessor :secret_word, :right_guesses, :wrong_letters

  private

  def save_game
    Dir.mkdir("saved_games") if !Dir.exists?("saved_games")
    if !@loaded_file_id
      list_files = Dir["saved_games/*"]
      list_ids = list_files.collect { |fname| fname.scan(/\d/).join.to_i }
      new_id = list_ids.empty? ? 1 : list_ids.max + 1
    else
      new_id = @loaded_file_id
    end
    File.open("saved_games/game#{new_id}.txt", "w").write(YAML::dump([self]))
    puts "file saved as game#{new_id}.txt"
    exit
  end

  def load_game
    
    if !Dir.exists?("saved_games")
      puts "There are no saved games to be loaded"
      return false
    end
    list_files = Dir["saved_games/*"]
    list_ids = list_files.collect { |fname| fname.scan(/\d/).join.to_i }
    if list_ids.empty?
      puts "There are no saved games to be loaded"
      return false
    end
    puts "Choose the id of the file to load: "
    puts list_ids.inspect
    id_load = gets.chomp
    if File.exists?("saved_games/game#{id_load}.txt")
      data = File.open("saved_games/game#{id_load}.txt", "r").readlines.join
      values = YAML::load(data)
      self.secret_word = values[0].secret_word
      self.right_guesses = values[0].right_guesses
      self.wrong_letters = values[0].wrong_letters
      @loaded_file_id = id_load
      return true
    end
    puts "File game#{id_load}.txt does not exist"
    false
  end

  public

  def play
    words = File.open("5desk.txt","r").readlines #dictionary file with one word per line
    begin
      puts "do you want to load a saved game? (y/n)"
      load_saved = gets[0].downcase
      if !((load_saved == "y") && load_game)
        @loaded_file_id = nil
        @secret_word = ""
        while !@secret_word.length.between?(5, 12) do
          @secret_word = words.sample.chomp.downcase
        end
        @right_guesses = Array.new(secret_word.length, "_ ").join
        @wrong_letters = []
      end
      num_of_guesses = Max_guesses - @wrong_letters.length
      while num_of_guesses > 0 do
        puts "\nIncorrect letters chosen: #{wrong_letters.join(' ')}" if !@wrong_letters.empty?
        puts "Wrong guesses left: #{num_of_guesses}\n\n"
        puts @right_guesses
    
        puts "\nGuess a letter or write '.' to save this game and quit."
        letter = gets[0].downcase
        save_game if letter == '.'
        while (@wrong_letters.include?(letter) || !letter.match(/[a-z]/)) do
          puts "You've already chosen that letter or the character introduced is not a letter. Please chose a different letter."
          letter = gets[0].downcase
        end
    
        secret_word_array = @secret_word.split("")
        positions = []
        secret_word_array.each_with_index {|l, i| positions.push(i) if l == letter}
        positions.each {|pos| @right_guesses[2*pos] = letter}
        if positions.empty?
          num_of_guesses -= 1
          @wrong_letters.push(letter)
          puts "\n The secret word does not contain that letter."
        end
        break if !@right_guesses.include?("_ ")
      end

      puts @right_guesses
      (num_of_guesses > 0)? puts("\nCongratulations, you guessed the secret word!") : puts("\nYou couldn't guess the secret word in #{Max_guesses} attempts.\nThe secret word was #{secret_word}")
      puts "\nPlay again? (y/n)"
    end while gets[0].downcase == "y"
  end
end

game = Hangman.new
game.play
