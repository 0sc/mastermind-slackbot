require "./lita-mastermind"

Lita.configure do |config|
  # The name your robot will use.
  config.robot.name = "mastermind-bot"
  config.robot.log_level = :info
  config.robot.adapter = :shell
  # config.robot.adapter = :slack
  # config.robot.admins  = [""]
  config.adapters.slack.token = "xoxb-12241522149-tijukNrZDpVGYYntbgmo55SF"
  config.robot.alias = "mastermind"
  # config.redis[:url] = ENV["REDISTOGO_URL"]
  # config.http.port = ENV["PORT"]
end
