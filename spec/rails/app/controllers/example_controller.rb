class ExampleController < ActionController::Base

  def show
    layout = params[:layout] == 'false' ? false : params[:layout]
    render params[:template], :layout => layout
  end

  def partial
    reuse_context = params[:context] != 'false'

    if reuse_context
      render :partial => 'arbre_partial', locals: { :arbre_context => Arbre::Context.new }
    else
      render :partial => 'arbre_partial'
    end
  end

end