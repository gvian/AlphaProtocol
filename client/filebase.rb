require "net/ftp"

module FileBase
  def FileBase::addfile(path)
    if path.nil?
      path = AP.input("path").gsub(File::ALT_SEPARATOR, File::SEPARATOR)
    end

    fname = File.basename(path, ".*")
    fext = File.extname(path)[1..-1]
    fdate = Time.new.to_i

    fname == "" ? fname = nil : nil
    fext == "" ? fext = nil : nil
    fdate == "" ? fdate = nil : nil

    keywords = AP.input("keywords").split(" ")
    owner = AP.input("owner")
    minPW = AP.input("minPW")

    $server ? nil : $server = AP.connect()
    if $server.nil?
      a = AP.input("Connettere automaticamente?")
    end

    if $server
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"INIT", :Name=>fname, :Ext=>fext, :Date=>fdate,
        :Keywords=>keywords, :Owner=>owner == "" ? nil : owner, :minPW=>minPW == "" ? nil : minPW}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      puts response[:Content][:Response]
      if response[:Code] == CODE_OK
        ticket = response[:Content][:Ticket]
        if FileBase.uploadfile(path, ticket)
          $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"SUBMIT", :Ticket=>ticket}}).to_json
          response = AP.jsontosym(JSON.parse($server.gets))
          puts response[:Content][:Response]
        end
      end
    else
      return false
    end
  end


  def FileBase::uploadfile(path, ticket)
    puts "Caricamento file..."
    begin
      ftp = Net::FTP.new
      ftp.connect(HOST, "12345")
      ftp.login("BAY", "bay")
      ftp.passive = true
      ftp.putbinaryfile(path, "#{ticket}#{File.extname(path)}")
      ftp.close
      return true
    rescue
      puts "C'e' stato un errore durante il trasferimento del file."
      return false
    end
  end
end