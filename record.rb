module Lita
  module Handlers
    class Record < Handler
      attr_reader :room
      def initialize(room)
        @room = room
      end

      def save_code (code)
        File.open(code_file, "w+"){|f| f.puts "#{code.join}|#{Time.now.strftime("%l:%M%P %b %d %Y")}"}
      end

      def retrieve_code(only_code = true)
        code = ''
        File.open(code_file, "r+"){ |f| code = f.gets.chomp}
        code = code.split("|")[0].split("") if only_code
        code
      end

      def file_exists?
        File.exist?(code_file)
      end

      def code_file
        "#{room}_game.txt"
      end

      def current_file
        "#{room}_current.txt"
      end

      def record_file
        "#{room}_record.txt"
      end

      def save_won(name, code)
        file = File.open(record_file,"a+")
        file.puts "New game: Mastermind generates `*#{code.join}*`  [#{get_game_start_time}]"

        File.open(current_file, "r+") do |f|
          f.each_line {|entry| file.puts entry}
        end
        file.puts "#{name} wins. Nice. \n\n"

        file.close
        delete_file
      end

      def save_guess(name, guess, exact, partial)
        File.open(current_file, "a+") do |f|
          f.puts "#{name} tries #{guess.join}: #{exact} exact and #{partial} partial match \t[#{Time.now.strftime("%l:%M%P %b %d %Y")}]"
        end
      end

      def leaderboard
        return false unless File.exist?(record_file)
        File.open(record_file, "r+")
      end

      def current_attempts
        return false unless File.exist?(current_file)
        File.open(current_file, "r+")
      end

      def get_game_start_time
        retrieve_code(false).split("|").last
      end

      def delete_file
        File.delete(code_file)
        File.delete(current_file)
      end

      Lita.register_handler(self)
    end
  end
end
