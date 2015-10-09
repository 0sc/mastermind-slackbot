require "./play"

module Lita
  module Handlers
    class Mastermind < Handler
      # insert handler code here
      route(/^(play)/, :play, command: true, help:{"play" => "Starts the Mastermind game if not already started. It takes a guess as optional argument"})
      route(/^try\s+(.+)/, :guess, command: true, help:{"try wxyz" => "Submit wxyz as a guess of the generated sequence."})
      route(/(instructions)$/, :instructions, command: true, help:{"instructions" => "Returns the game instrutions"})
      route(/^records/, :record, command: true, help:{"records" => "Returns a record of all games played in this channel. Does not include active game; use 'current' for active games"})
      route(/^guesses/, :current, command: true, help:{"guesses" => "Returns a record of all trys at the current active game session"})
      # route(/^[stop, quit, end]$/, :quit, command: true, help:{"quit" => "Replies back with Text."})

      def play(response)
        @obj = create_obj(response)
        response.reply(@obj.info.join(" "))
        if response.args[0]
           game_feedback(response)
        end
      end

      # def quit(response)
      # end

      def guess(response)
        @obj = create_obj(response)
        input ||= response.args[0]
         game_feedback(response)
        # response.reply_with_mention("I cached you guess #{response.args} #{response.user.mention_name} asdfs #{response.room.name}")
        # # response.reply("I cached your code #{@obj.code}")
      end

      def instructions(response)
        response.reply("Mastermindbot v0.0.1-beta. Implements the awesomely difficult classic game of same name. In this implementation, Mastermindbot selects a random 4 character sequence of colors from (r)ed, (g)reen, (y)ellow, (b)lue i.e(rgyb). Your challenge is to try and guess the sequence using the very helpful feedback provided after each attempt. Note that characters could be repeated e.g rrrb, ggbg, etc")
        response.reply("Once a game session is started, except for DMs, everyone in the channel or group can take part in guessing the right sequence. You can view guesses `@mastermindbot guesses by others to aid in getting the sequence.")
        response.reply("Your commands, except for DMs, should be prefixed with a mention of the bot, e.g `@mastermindbot play`, `mastermind records`. Enter @mastermindbot to view commands the bot responds to.")
      end

      def record(response)
        file = Record.new(response.room.name).leaderboard
        get_scores(response, file)
      end

      def current(response)
        file = Record.new(response.room.name).current_attempts
        get_scores(response, file)
      end

      private

      def create_obj(response)
        obj = Play.new(response.user.mention_name, response.room.name)
        obj.start_game
        obj
      end

      def game_feedback(response)
        @obj.info=([])
        @obj.analyze_input(response.args[0])
        response.reply_with_mention(@obj.info.join(" "))
      end

      def get_scores(response,file)
        return response.reply("Be the first of your friends to play ;) ") if !file

        file.each_line do |entry|
          response.reply(entry)
        end
        file.close
      end

      Lita.register_handler(self)
    end
  end
end
