load("env.rb")

SpeedStat.create!.run
SpeedStat.write_html
SpeedStat.ftp
