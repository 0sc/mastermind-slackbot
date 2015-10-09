require "./record"

module Lita
  module Handlers
    class Play < Handler
      attr_reader :code, :room
      attr_accessor :info
      def initialize (user, room)
        @user = user
        @room = room
        @info = []
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
          @info << "Game started"
        else
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

        @record.save_guess(@user, input)
        input = input.split("")
        if (code == input)
          @info << " you rock! You found the correct sequence. Awesome :)"
          @record.save_won(@user, code)
        else
          exact = exact_match(code, input)
          partial = partial_match(code, input, exact)
          exact = exact.size

          give_guess_feedback(input, exact, partial)
        end
      end

      def validate_input(input)
        if (input.size != @char_length)
          @info << "Oops! Wrong input. Your guess should be 4 characters"
          return false
        end
        true
      end

      def exact_match(game_code,input)
        exact = []
        input.each_index do |index|
          exact << index if game_code[index] == input[index]
        end
        exact
      end

      def partial_match(game_code, input,exact)
        partials = [] + game_code
        exact.each{|elt| partials[elt] = nil}
        partial = 0

        input.each_with_index do |item, index|
          pIndex = partials.index(item)

          if(pIndex && !exact.include?(index))
            partial += 1
            partials[pIndex] = nil
          end
        end
        partial
      end

      def give_guess_feedback(input, exact, partial)
        @info << "Hmmm! Your guess, `{input.join}`, has #{exact + partial} of the correct elements with #{exact} in the correct positions."
      end

      Lita.register_handler(self)
    end
  end
end
