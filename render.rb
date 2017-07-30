load("env.rb")

SpeedStat.create!.run unless SpeedStat.exists?
system("open #{SpeedStat.write_html}")
