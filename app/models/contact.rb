class Contact < ActiveRecord::Base
	require 'csv'
	include SaveWithErrors

	validates_uniqueness_of :firstname, :lastname, :email
	validates_format_of :email, :with => /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validate :check_length
	validate :lastname, :firstname, if: :capitalize_name? 
	validate :chars_valid?

	def self.import(file)
	  spreadsheet = Roo::Spreadsheet.open(file.path)
	  header = spreadsheet.row(1)
	  (2..spreadsheet.last_row).each do |i|
	    row = Hash[[header, spreadsheet.row(i)].transpose]
	   	contact_hash = row.to_hash
			contact = where(firstname: contact_hash["firstname"])
			contact = where(lastname: contact_hash["lastname"])
			contact = where(email: contact_hash["email"])
			if contact.count == 1
				puts "already exist"
			else
				contact.create!(contact_hash)
			end 
  	end
	end  

	def self.open_spreadsheet(file)
		case File.extname(file.original_filename)
		when ".csv" then Roo::CSV.new(file.path, nil, :ignore)
		when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
		when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
		else raise "Unknown file type: #{file.original_filename}"
		end
	end

	def check_length
		if (self.lastname || self.firstname).length < 3
			errors.add :lastname, 'your firstname or lastname is less than 3 character'
		end
	end

	def capitalize_name?
		if self.lastname[0] && self.firstname[0] == (self.lastname[0] && self.firstname[0]).upcase
			puts "it' ok!"
		else
			errors.add :lastname, 'your firstname or lastname must begin with an upercase'.to_sentence
			errors.add :firstname, 'your firstname or lastname must begin with an upercase'
			self.lastname.capitalize!
			self.firstname.capitalize!
		end
	end

	def chars_valid?
		if (self.lastname && self.firstname).match(/[^a-zA-Z\-]/)
			errors.add :lastname, 'only letters is allowed'
			errors.add :firstname, 'only letters is allowed'
			self.firstname.gsub!(/[^a-zA-Z\-]/,"")
			self.lastname .gsub!(/[^a-zA-Z\-]/,"")
		end 
	end
end
