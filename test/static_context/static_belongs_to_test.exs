defmodule StaticContext.StaticBelongsToTest do
  use StaticContext.Test.DataCase

  alias StaticContext.Test.Article
  alias StaticContext.Test.Category

  describe "static_belongs_to/2" do
    test "loads full struct when reading from DB" do
      user = Factory.insert(:user)
      Factory.insert(:article, user_id: user.id, title: "Test", category_id: "news")

      article = Repo.get_by!(Article, title: "Test")
      assert %Category{id: "news", name: "News"} = article.category
    end

    test "stores string id in the database" do
      user = Factory.insert(:user)
      Factory.insert(:article, user_id: user.id, title: "Test", category_id: "tutorial")

      article = Repo.get_by!(Article, title: "Test")
      assert article.category_id == "tutorial"
    end

    test "category is nil when category_id is nil" do
      user = Factory.insert(:user)
      Factory.insert(:article, user_id: user.id, title: "No Category")

      article = Repo.get_by!(Article, title: "No Category")
      assert is_nil(article.category)
      assert is_nil(article.category_id)
    end

    test "schema has both _id and struct fields" do
      assert %Article{category_id: nil, category: nil} = %Article{}
    end
  end
end
