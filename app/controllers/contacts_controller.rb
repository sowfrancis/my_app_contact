class ContactsController < ApplicationController
	def index
		@contacts_without_error = Contact.where(record_error: nil)
		@contacts_with_error = Contact.where.not(record_error: nil)
	end

	def import
		@contact = Contact.import(params[:file])
  	redirect_to root_url, notice: "Contact imported."
	end
end
