class V1::ArticlesController < ApplicationController
  def index
    articles = Article.all
    render json: { articles: article_short_infos(articles) }
  end

  private

  def article_short_infos(articles)
    articles.map do |article|
      json = article.as_json(only: [:id, :title, :word_count])
      json.deep_transform_keys! { |key| key.camelize(:lower) }
      json
    end
  end
end
