load("env.rb")

SpeedStat.create!.run unless SpeedStat.exists?
SpeedStat.write_html
SpeedStat.ftp
