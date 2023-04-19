Rails.application.routes.draw do
    get 'news', to: 'news#index'
  get 'news/audio', to: 'news#audio', as: 'audio'
end
