require "./record"

module Lita
  module Handlers
    class Play < Handler
      attr_reader :code, :room, :new_game
      attr_accessor :info
      def initialize (user, room)
        @user = user
        @room = room
        @info = []
        @new_game = false
        @record = Record.new(room)
        @char_length = 4
      end

      def check_if_any_game_in_progress
        return if !@record.file_exists?
        @record.retrieve_code
      end

      def start_game
        @code = check_if_any_game_in_progress
        if @code != nil
          @info << "Mastermind game already in progress :simple_smile:. Started: #{@record.get_game_start_time}. Enter mastermind guesses to view guesses so far."
        else
          @new_game = true
          @code = create_code
          @info << start_info
        end

      end

      def create_code
        colors = %w(r g b y c m)
        code = []
        @char_length.times do
          index = rand(0..@char_length)
          code << colors[index]
        end
        @record.save_code(code)
        code
      end

      def start_info
        "Hello #{@user}, I've generated a four character string from the characters: `r, b, g, y, c`. Can you guess the string?"
      end

      def analyze_input(input)
        return unless validate_input(input)

        input = input.split("")
        if (code == input)
          @info << "you rock! You found the correct sequence. Awesome :clap:"
          @record.save_guess(@user, input, @char_length, 0)
          @record.save_won(@user, code)
        else
          partial_exact_matches = new_partial_exact_match(code, input)
          exact = partial_exact_matches[:exact]
          partial = partial_exact_matches[:partial]
          # exact = exact_match(code, input)
          # partial = partial_match(code, input, exact)
          exact = exact.size
          @record.save_guess(@user, input, exact, partial)
          give_guess_feedback(input, exact, partial)
        end
      end

      def validate_input(input)
        if (input.size != @char_length)
          @info << "Oops! Wrong input. Your guess should be 4 characters :anguished:"
          return false
        end
        true
      end
      
      def new_partial_exact_match(game_code, input)
          partials = [] + game_code
          exact = []
          partial = 0
          
          input.each_with_index{ |elt, ind|
              pIndex = partials.index(elt)
              exact << ind if game_code[ind] == input[ind]
             pIndex = partials.index(elt)
             
             if(pIndex && !exact.include?(ind))
              partial += 1
              partials[pIndex] = nil
            end
          }
          # [exact, partial]
          {exact: exact, partial: partial}
      end

      # def exact_match(game_code,input)
      #   exact = []
      #   input.each_index do |index|
      #     exact << index if game_code[index] == input[index]
      #   end
      #   exact
      # end

      # def partial_match(game_code, input,exact)
      #   partials = [] + game_code
      #   exact.each{|elt| partials[elt] = nil}
      #   partial = 0

      #   input.each_with_index do |item, index|
      #     pIndex = partials.index(item)

      #     if(pIndex && !exact.include?(index))
      #       partial += 1
      #       partials[pIndex] = nil
      #     end
      #   end
      #   partial
      # end

      def give_guess_feedback(input, exact, partial)
        @info << "Hmmm! Your guess, `#{input.join}`, has #{exact + partial} of the correct elements with #{exact} in the correct positions. :smirk:"
      end

      Lita.register_handler(self)
    end
  end
end
