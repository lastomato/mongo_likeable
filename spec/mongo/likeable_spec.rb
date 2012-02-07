require 'spec_helper'

describe Mongo::Likeable do

  describe User do

    let!(:u) { User.new }

    context "likes & dislikes" do

      before do
      	u.save

        @v = User.new
        @v.save

        @s = Stuff.new
        @s.save

        @t = Stuff.new
        @t.save
      end

      it "likes something" do
        u.like?(@v).should be_false
        u.like?(@s).should be_false

        u.dislike?(@v).should be_false
        u.dislike?(@s).should be_false

        u.like(@v, @s, @t)
        u.like_counts.should == 3
        u.likes.should =~ [@v.class.name + '_' + @v.id.to_s, @s.class.name + '_' + @s.id.to_s, @t.class.name + '_' + @t.id.to_s]
#        u.like_history.should =~ [@v.class.name + '_' + @v.id.to_s, @s.class.name + '_' + @s.id.to_s, @t.class.name + '_' + @t.id.to_s]

        u.dislike(@v, @s, @t)
        u.dislikes.should =~ [@v.class.name + '_' + @v.id.to_s, @s.class.name + '_' + @s.id.to_s, @t.class.name + '_' + @t.id.to_s]
#        u.dislike_history.should =~ [@v.class.name + '_' + @v.id.to_s, @s.class.name + '_' + @s.id.to_s, @t.class.name + '_' + @t.id.to_s]

        u.clear_likes(@v, @s)
        u.like_counts.should == 1
        u.likes.should =~ [@t.class.name + '_' + @t.id.to_s]
#        u.like_history.should =~ [@v.class.name + '_' + @v.id.to_s, @s.class.name + '_' + @s.id.to_s, @t.class.name + '_' + @t.id.to_s]

        u.clear_dislikes()
        u.dislike_counts.should == 0
        u.dislikes.should == []
#        u.dislike_history.should =~ [@v.class.name + '_' + @v.id.to_s, @s.class.name + '_' + @s.id.to_s, @t.class.name + '_' + @t.id.to_s]

      end
    end
  end
end
