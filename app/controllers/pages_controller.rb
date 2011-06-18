class PagesController < ApplicationController
  
  caches_page :home, :help, :rules, :contact
  
  def home
    @categories = Category.all
  end

  def help
  	@title = "| Help"
  end
  
  def rules
  	@title = "| Rules"
  end
  
  def contact
  	@title = "| Contact"
  end

end
