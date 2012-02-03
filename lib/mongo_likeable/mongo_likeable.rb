module Mongo
  module Likeable
    extend ActiveSupport::Concern

    included do |base|
      if defined?(Mongoid)
        base.field :likes, :type => Array, :default => []
        base.field :dislikes, :type => Array, :default => []
      elsif defined?(MongoMapper)
        base.key :likes, :type => Array, :default => []
        base.key :dislikes, :type => Array, :default => []
      end
    end

    module ClassMethods
      #...
    end

    def like(*models)
      self.likes |= simplify_instance(*models)
    end

    def dislike(*models)
      self.dislikes |= simplify_instance(*models)
    end

    def like?(model)
      self.likes.include? simplify_instance(model)
    end

    def dislike?(model)
      self.dislikes.include? simplify_instance(model)
    end

    def clear_likes(*models)
      if models == []
        self.likes = []
      else
        self.likes -= simplify_instance(*models)
      end
    end

    def clear_dislikes(*models)
      if models == []
        self.dislikes = []
      else
        self.dislikes -= simplify_instance(*models)
      end
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
