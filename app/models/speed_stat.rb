require 'net/ftp'
class SpeedStat < ActiveRecord::Base

  def run
    speedtest = `speedtest-cli --share --server=5351 --json`

    json = JSON.parse(speedtest)
    self.ping = json["ping"]
    self.upload = json["upload"]
    self.download = json["download"]
    self.url = json["share"]
    self.save!
    puts self.results
  end

  def results
    arr = [
      "Time: " + self.created_at.to_s.ljust(10),
      "Download: " + Filesize.from("#{self.download.to_s} B").pretty.ljust(10),
      "Upload: " + Filesize.from("#{self.upload.to_s} B").pretty.ljust(10),
      "Ping: #{self.ping.to_s} ms".ljust(10),
      "URL: #{self.url.to_s}".ljust(10),
    ].join(" | ")
  end

  def output
    SpeedStat.order("created_at desc").find_in_batches do |group|
      group.each do |l|
        puts l.results
      end
    end
  end

  def self.write_html
    series = {
      ping: {
        name: "Ping",
        data: []
      },
      upload: {
        name: "Upload",
        data: []
      },
      download: {
        name: "Download",
        data: []
      }
    }
    SpeedStat.order("created_at desc").find_in_batches do |group|
      group.each do |l|
        #series[:ping][:data] << [l.created_at.to_i * 1000, l.ping.round(2)]
        series[:download][:data] << [l.created_at.to_i * 1000, Filesize.from("#{l.download} B").to_f('MB').round(2)]
        series[:upload][:data] << [l.created_at.to_i * 1000, Filesize.from("#{l.upload} B").to_f('MB').round(2)]
      end
    end
    @data = []
    #@data << series[:ping]
    @data << series[:download]
    @data << series[:upload]

    puts template = File.read('./files/index.html.haml')
    haml_engine = Haml::Engine.new(template)
    output = haml_engine.render(Object.new, { :@data => @data })

    File.open('output.html', 'wb') {|a| a.write(output) }
    return "output.html"
  end

  def self.ftp
    puts "Uploading to #{ENV["FTP_SERVER"]}"
    filecontent = File.binread('./output.html')
    Net::FTP.open(ENV["FTP_SERVER"]) do |ftp|
      ############ UPLOAD NORMAL FILE ############
      ftp.login(ENV["FTP_USERNAME"], ENV["FTP_PASSWORD"])
      ftp.passive = true
      ftp.binary = true
      ftp.chdir(ENV["FTP_PATH"] || "/")
      ftp.storbinary("STOR index.html", StringIO.new(filecontent), 1024)
      ftp.close
    end
  end
end
