module Mongo
  module Likeable
    extend ActiveSupport::Concern

    included do |base|
      if defined?(Mongoid)
        base.field :likes, :type => Array, :default => []
        base.field :dislikes, :type => Array, :default => []

        base.field :likers, :type => Array, :default => []
        base.field :dislikers, :type => Array, :default => []

        base.field :like_histories, :type => Array, :default => []
        base.field :dislike_histories, :type => Array, :default => []
      elsif defined?(MongoMapper)
        base.key :likes, :type => Array, :default => []
        base.key :dislikes, :type => Array, :default => []

        base.key :likers, :type => Array, :default => []
        base.key :dislikers, :type => Array, :default => []

        base.key :like_histories, :type => Array, :default => []
        base.key :dislike_histories, :type => Array, :default => []
      end
    end

    def like(*models)
      self.likes |= simplify_instance(*models)
      self.like_histories |= simplify_instance(*models)

      models.each do |model|
        model.likers |= simplify_instance(self)

        model.save
      end

      self.save
    end

    def dislike(*models)
      self.dislikes |= simplify_instance(*models)
      self.dislike_histories |= simplify_instance(*models)

      models.each do |model|
        model.likers |= simplify_instance(self)

        model.save
      end

      self.save
    end

    def like_counts
      self.likes.length
    end

    def dislike_counts
      self.dislikes.length
    end

    def all_likers
      rebuild_instance(*self.likers)
    end

    def all_dislikers
      rebuild_instance(*self.dislikers)
    end

    def like_history
      rebuild_instance(*self.like_histories)
    end

    def dislike_history
      rebuild_instance(*self.dislike_histories)
    end

    def like?(model)
      self.likes.include? simplify_instance(model)[0]
    end

    def dislike?(model)
      self.dislikes.include? simplify_instance(model)[0]
    end

    def clear_likes(*models)
      if models == []
        self.likes = []
      else
        self.likes -= simplify_instance(*models)

        models.each do |model|
          model.likers -= simplify_instance(self)

          model.save
        end
      end

      self.save
    end

    def clear_dislikes(*models)
      if models == []
        self.dislikes = []
      else
        self.dislikes -= simplify_instance(*models)

        models.each do |model|
          model.likers -= simplify_instance(self)

          model.save
        end
      end

      self.save
    end

    private
      def rebuild_instance(*abbrs)
        list = []
        abbrs.each do |abbr|
          classname = abbr.split('_')[0]
          id = abbr.split('_')[1]

          list << classname.constantize.find(id)
        end
        list
      end

      def simplify_instance(*models)
        list = []
        models.each do |model|
          list << model.class.name + '_' + model.id.to_s
        end
        list
      end
  end
end
