Combustion::Application.routes.draw do
  get '/' => 'example#show'
  get '/partial' => 'example#partial'
end