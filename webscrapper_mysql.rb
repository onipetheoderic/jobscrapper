require 'open-uri'
require 'nokogiri'
require 'mysql2'
require 'watir'



@db_name = "webscrapper"


begin
  #my = Mysql.new(hostname, username, password, databasename) 
    # con = Mysql.new('localhost', 'root', 't1t2t3t4', 'webscrapper')
    con = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "t1t2t3t4")
    puts con.server_info
    # con.query("DROP DATABASE IF EXISTS #{@db_name}")
    # SHOW COLUMNS FROM table_name.
    con.query("CREATE DATABASE IF NOT EXISTS webscrapper")
    con.query("USE webscrapper;") 
    con.query("CREATE TABLE IF NOT EXISTS Job(
    Id INT AUTO_INCREMENT primary key NOT NULL,
    Job_name varchar(255),
    Day_posted varchar(255),
    Company_location varchar(255),
    Company_name varchar(255),
    Job_function VARCHAR(300),
    job_salary VARCHAR(50), 
    job_summary VARCHAR(5500),
    Job_description VARCHAR(5500),
    Job_experience_length VARCHAR(5500),
    Job_experience_level VARCHAR(5500), 
    Job_minimum_qualification VARCHAR(500)
);")
    
    
rescue Mysql2::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end




def db_save(job_name, day_posted, company_location,
            company_name, job_function, job_salary, 
            job_summary, job_description, job_experience_length,
            job_experience_level, job_minimum_qualification)

         @stringified_job_name = job_name.encode('UTF-8','ISO-8859-1')
         @stringified_day_posted = day_posted.encode('UTF-8','ISO-8859-1')
         @stringified_company_location = company_location.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_company_name = company_name.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_job_function = job_function.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_job_salary = job_salary.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_job_summary = job_summary.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_job_description = job_description.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_job_experience_length = job_experience_length.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_experience_level = job_experience_level.to_s.encode('UTF-8','ISO-8859-1')
         @stringified_job_minimum_qualification = job_minimum_qualification.to_s.encode('UTF-8','ISO-8859-1')

    @con.exec "INSERT INTO Jobs VALUES(
   DEFAULT,
   '#{@stringified_job_name}',
   '#{@stringified_day_posted}',
   '#{@stringified_company_location}',
   '#{@stringified_company_name}',
   '#{@stringified_job_function}',
   '#{@stringified_job_salary}',
   '%Q(@stringified_job_summary)',
   '%Q(@stringified_job_description)',
   '%Q(@stringified_job_experience_length)',
   '%Q(@stringified_experience_level)',
   '%Q(@stringified_job_minimum_qualification)'   
   )"    
   puts "__________________Record Successfuly Saved to the DATABASE_________________"
end



def get_detailsNsave(link, day, location, company, salary, function, name)
  link_string = link.to_s
  doc_detail = Nokogiri::HTML(open(link_string))  
   #job summary
   puts "Job SUMMARY"
  puts doc_detail.css('div.job__details__user-edit p')[0]
   @job_summary = doc_detail.css('div.job__details__user-edit p')[0]

   puts "JOB DESCRIPTIon"
   puts doc_detail.css('div.job__details__user-edit p')[1..-1].text.strip
   @job_description = doc_detail.css('div.job__details__user-edit p')[1..-1].text.strip
   
   puts "JOB QUAliFICation"
   doc_detail.css('.font--weight-300').each do |qualification|
      #minimum qualification
      puts qualification.css('li')[0].text.strip
      @minimun_qualification = qualification.css('li')[0].text.strip
      #Experience level
      puts qualification.css('li')[1].text.strip
      @experience_level = qualification.css('li')[1].text.strip
      #Experience Length
      puts qualification.css('li')[2].text.strip
      @experience_length = qualification.css('li')[2].text.strip
   end
   #get_detailsNsave(link, day, location, company, salary, function, name)
# db_save(name, day, location, company, function, salary, 
#             @job_summary, @job_description, @experience_length,
#             @experience_level, @experience_length)
end





doc = Nokogiri::HTML(open("https://www.jobberman.com/jobs"))
@page_title = doc.css('title')


puts @page_title
doc.css('article.search-result').each do |el|
	#header job_name
   @name = el.css('h3').text.gsub(/\s+/, " ").strip
   puts @name   
 
   #job functions
   @function = el.css('span.gutter-flush-under-lg').text.gsub(/\s+/, " ").strip
   puts @function

   #job salary
   el.css('.search-result__job-salary').each do |result|
      @salary = result.content.gsub(/\s+/, " ").strip
      puts @salary

   end
   #to get the company name
   el.css('.search-result__job-meta').each do |result|
      @company = result.content.gsub(/\s+/, " ").strip
      puts @company
   end
   #to get the company location
   el.css('.search-result__location').each do |result|
      @location = result.content.gsub(/\s+/, " ").strip
      puts @location

   end
   #to get the days since posted
   el.css('.if-wrapper-column').each do |result|
      @day = result.content.gsub(/\s+/, " ").strip
      puts @day

   end

   @links = el.css("a")[0]["href"]
   puts @links
   get_detailsNsave(@links, @day, @location, @company, @salary, @function, @name)
  
end

