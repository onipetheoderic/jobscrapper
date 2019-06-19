require 'open-uri'
require 'nokogiri'
require 'watir'



def get_details(link)
	link_string = link.to_s
	doc_detail = Nokogiri::HTML(open(link_string))
	
   #job summary
   puts "Job SUMMARY"
	puts doc_detail.css('div.job__details__user-edit p')[0]

   puts "JOB DESCRIPTIon"
   # puts doc_detail.css('div.job__details__user-edit p li b')[1..-1].text.strip

   puts "JOB QUAliFICation"
   doc_detail.css('.font--weight-300').each do |qualification|
      #minimum qualification
      puts qualification.css('li')[0].text.strip
      #Experience level
      puts qualification.css('li')[1].text.strip
      #Experience Length
      puts qualification.css('li')[2].text.strip
    end
end


@browser = Watir::Browser.new
def pageUrl_displayer
	puts "Finished Scrapping: #{@browser.url}"
end

def paginator_accessor	
	@browser.goto("https://www.jobberman.com/jobs")

	while !@browser.span(text: "Next").exists?
		puts "Scrapping of #{@browser.url}"

		doc = Nokogiri::HTML.parse(@browser.html)
		@page_title = doc.css('title').text
		puts @page_title
		doc.css('article.search-result').each do |el|
			#header
			puts el.css('h3').text.gsub(/\s+/, " ").strip		
			#job functions
			puts el.css('span.gutter-flush-under-lg').text.gsub(/\s+/, " ").strip
			#to get the salary
			el.css('.search-result__job-salary').each do |result|
      			puts result.content.gsub(/\s+/, " ").strip
   			end
   			#to get the company name
			el.css('.search-result__job-meta').each do |result|
			  puts result.content.gsub(/\s+/, " ").strip
			end
			 #to get the company location
			el.css('.search-result__location').each do |result|
			  puts result.content.gsub(/\s+/, " ").strip
			end
					#to get the days since posted
			el.css('.if-wrapper-column').each do |result|
			  puts result.content.gsub(/\s+/, " ").strip
			end
			#to get the  days ago posted
			@links = el.css("a")[0]["href"]
			puts @links
			get_details(@links)

		end
		@browser.link(text: "Next").click
	end
end



 paginator_accessor

#while li class is equal to active do this
#if @browser.span(text: "Next").exists?
		#puts "Not Nextable, this is at the end of the jobberman page"
	#else
	#	@browser.link(text: "Next").click #this is how to click the next
	#end
	#https://www.jobberman.com/jobs?page=46
	# browser.link(text: page_number.to_s).click
	#how to know if it exists
#if @browser.span(text: "Next").exists?
		#puts "there is a next"
	#end




#We first of all create an instance of the watir browser=> Watir::Browser.new
#Once we have created the instance of the watir browser, we can send it commands
#like browser.goto "www.google.com"
#Elements can be found by using there html attributes such as name, class, id,
#e.g browser.button(:name => "submit")
#You can also ask watir to return all types of an element from a page 
#e.g browser.h1s, this displays all the h1 in the page