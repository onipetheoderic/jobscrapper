require 'mysql2'
# to get user inputs

# puts "Dropping Databased named: #{db_name}"

begin
	con = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "t1t2t3t4")

    db_name = gets.chomp
	con.query("DROP DATABASE IF EXISTS #{db_name};")
rescue Mysql2::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end