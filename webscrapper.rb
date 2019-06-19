require 'open-uri'
require 'nokogiri'
require 'pg'


begin
    @con = PG.connect :dbname => 'webscrapper', :user => 'postgres', :password => 'theoderic'
    @server_version = @con.server_version
    @con.set_client_encoding('UTF-8')
    
    @db_name = @con.db()
    @db_host_name = @con.host()
    @conn_message = "#{@db_name} has been connected to the host #{@db_host_name} successfully, server version: #{@server_version}"
    puts @conn_message
   @con.exec "CREATE TABLE IF NOT EXISTS Jobs(
      Id SERIAL, 
      job_name VARCHAR(120),
      day_posted VARCHAR(20),
      company_location VARCHAR(30),
      company_name VARCHAR(100),
      job_function VARCHAR(300),
      job_salary VARCHAR(50), 
      job_summary VARCHAR(5500),
      job_description VARCHAR(5500),
      job_experience_length VARCHAR(5500),
      job_experience_level VARCHAR(5500), 
      job_minimum_qualification VARCHAR(500)
   )"
#create this as a unique field
  # https://www.jobberman.com/job/sales-executive-48d6ke
    puts "Webscrapping started................."  
rescue PG::Error => e
    puts e.message     
# ensure
#     @con.close if @con    
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
#get_detailsNsave(@links, @day, @location, @company, @salary, @function, @name)
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
db_save(name, day, location, company, function, salary, 
            @job_summary, @job_description, @experience_length,
            @experience_level, @experience_length)
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

