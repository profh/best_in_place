# encoding: utf-8

describe BestInPlace::Helper, type: :helper do
  describe "#best_in_place" do
    before do

      @user = User.new :name => "Lucia",
        :last_name => "Napoli",
        :email => "lucianapoli@gmail.com",
        :height => "5' 5\"",
        :address => "Via Roma 99",
        :zip => "25123",
        :country => "2",
        :receive_email => false,
        :birth_date => Time.now.utc.to_date,
        :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
        :money => 150
    end

    it "should generate a proper id for namespaced models" do
      @car = Cuca::Car.create :model => "Ford"

      nk = Nokogiri::HTML.parse(helper.best_in_place @car, :model, :path => helper.cuca_cars_path)
      span = nk.css("span")
      expect(span.attribute("id").value).to eq("best_in_place_cuca_car_#{@car.id}_model")
    end

    it "should generate a proper span" do
      nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
      span = nk.css("span")
      expect(span).not_to be_empty
    end

    it "should not allow both display_as and display_with option" do
      expect { helper.best_in_place(@user, :money, :display_with => :number_to_currency, :display_as => :custom) }.to raise_error(ArgumentError)
    end

    describe "general properties" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      context "when it's an ActiveRecord model" do
        it "should have a proper id" do
          expect(@span.attribute("id").value).to eq("best_in_place_user_#{@user.id}_name")
        end
      end

      context "when it's not an AR model" do
        it "shold generate an html id without any id" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [1,2,3], :first, :path => @user)
          span = nk.css("span")
          expect(span.attribute("id").value).to eq("best_in_place_array_first")
        end
      end

      it "should have the best_in_place class" do
        expect(@span.attribute("class").value).to eq("best_in_place")
      end

      it "should have the correct data-attribute" do
        expect(@span.attribute("data-attribute").value).to eq("name")
      end

      it "should have the correct data-object" do
        expect(@span.attribute("data-object").value).to eq("user")
      end

      it "should have no activator by default" do
        expect(@span.attribute("data-activator")).to be_nil
      end

      it "should have no OK button text by default" do
        expect(@span.attribute("data-ok-button")).to be_nil
      end

      it "should have no OK button class by default" do
        expect(@span.attribute("data-ok-button-class")).to be_nil
      end

      it "should have no Cancel button text by default" do
        expect(@span.attribute("data-cancel-button")).to be_nil
      end

      it "should have no Cancel button class by default" do
        expect(@span.attribute("data-cancel-button-class")).to be_nil
      end

      it "should have no Use-Confirmation dialog option by default" do
        expect(@span.attribute("data-use-confirm")).to be_nil
      end

      it "should have no inner_class by default" do
        expect(@span.attribute("data-inner-class")).to be_nil
      end

      describe "url generation" do
        it "should have the correct default url" do
          @user.save!
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          expect(span.attribute("data-url").value).to eq("/users/#{@user.id}")
        end

        it "should use the custom url specified in string format" do
          out = helper.best_in_place @user, :name, :path => "/custom/path"
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-url").value).to eq("/custom/path")
        end

        it "should use the path given in a named_path format" do
          out = helper.best_in_place @user, :name, :path => helper.users_path
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-url").value).to eq("/users")
        end

        it "should use the given path in a hash format" do
          out = helper.best_in_place @user, :name, :path => {:controller => :users, :action => :edit, :id => 23}
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-url").value).to eq("/users/23/edit")
        end
      end

      describe "nil option" do
        it "should have no nil data by default" do
          expect(@span.attribute("data-nil")).to be_nil
        end

        it "should show '' if the object responds with nil for the passed attribute" do
          expect(@user).to receive(:name).and_return("")
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          expect(span.text).to eq("")
        end

        it "should show '' if the object responds with an empty string for the passed attribute" do
          expect(@user).to receive(:name).and_return("")
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          expect(span.text).to eq("")
        end
      end

      it "should have the given inner_class" do
        out = helper.best_in_place @user, :name, :inner_class => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-inner-class").value).to eq("awesome")
      end

      it "should have the given activator" do
        out = helper.best_in_place @user, :name, :activator => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-activator").value).to eq("awesome")
      end

      it "should have the given OK button text" do
        out = helper.best_in_place @user, :name, :ok_button => "okay"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-ok-button").value).to eq("okay")
      end

      it "should have the given OK button class" do
        out = helper.best_in_place @user, :name, :ok_button => "okay", :ok_button_class => "okay-class"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-ok-button-class").value).to eq("okay-class")
      end

      it "should have the given Cancel button text" do
        out = helper.best_in_place @user, :name, :cancel_button => "nasty"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-cancel-button").value).to eq("nasty")
      end

      it "should have the given Cancel button class" do
        out = helper.best_in_place @user, :name, :cancel_button => "nasty", :cancel_button_class => "nasty-class"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-cancel-button-class").value).to eq("nasty-class")
      end

      it "should have the given Use-Confirmation dialog option" do
        out = helper.best_in_place @user, :name, :use_confirm => "false"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-use-confirm").value).to eq("false")
      end

      describe "object_name" do
        it "should change the data-object value" do
          out = helper.best_in_place @user, :name, :object_name => "my_user"
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-object").value).to eq("my_user")
        end
      end

      it "should have html5 data attributes" do
        out = helper.best_in_place @user, :name, :data => { :foo => "awesome", :bar => "nasty" }
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-foo").value).to eq("awesome")
        expect(span.attribute("data-bar").value).to eq("nasty")
      end

      describe "display_as" do
        it "should render the address with a custom renderer" do
          expect(@user).to receive(:address_format).and_return("the result")
          out = helper.best_in_place @user, :address, :display_as => :address_format
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("the result")
        end
      end

      describe "display_with" do
        it "should render the money with the given view helper" do
          out = helper.best_in_place @user, :money, :display_with => :number_to_currency
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("$150.00")
        end

        it "accepts a proc" do
          out = helper.best_in_place @user, :name, :display_with => Proc.new { |v| v.upcase }
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("LUCIA")
        end

        it "should raise an error if the given helper can't be found" do
          expect { helper.best_in_place @user, :money, :display_with => :fk_number_to_currency }.to raise_error(ArgumentError)
        end

        it "should call the helper method with the given arguments" do
          out = helper.best_in_place @user, :money, :display_with => :number_to_currency, :helper_options => {:unit => "º"}
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("º150.00")
        end
      end

      describe "array-like objects" do
        it "should work with array-like objects in order to provide support to namespaces" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [:admin, @user], :name)
          span = nk.css("span")
          expect(span.text).to eq("Lucia")
        end
      end
    end

    context "with a text field attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      it "should render the name as text" do
        expect(@span.text).to eq("Lucia")
      end

      it "should have an input data-type" do
        expect(@span.attribute("data-type").value).to eq("input")
      end

      it "should have no data-collection" do
        expect(@span.attribute("data-collection")).to be_nil
      end
    end

    context "with a date attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :birth_date, :type => :date)
        @span = nk.css("span")
      end

      it "should render the date as text" do
        expect(@span.text).to eq(@user.birth_date.to_date.to_s)
      end

      it "should have a date data-type" do
        expect(@span.attribute("data-type").value).to eq("date")
      end

      it "should have no data-collection" do
        expect(@span.attribute("data-collection")).to be_nil
      end
    end

    context "with a boolean attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, :type => :checkbox)
        @span = nk.css("span")
      end

      it "should have a checkbox data-type" do
        expect(@span.attribute("data-type").value).to eq("checkbox")
      end

      it "should have the default data-collection" do
        data = ["No", "Yes"]
        expect(@span.attribute("data-collection").value).to eq(data.to_json)
      end

      it "should render the current option as No" do
        expect(@span.text).to eq("No")
      end

      describe "custom collection" do
        before do
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, :type => :checkbox, :collection => ["Nain", "Da"])
          @span = nk.css("span")
        end

        it "should show the message with the custom values" do
          expect(@span.text).to eq("Nain")
        end

        it "should render the proper data-collection" do
          expect(@span.attribute("data-collection").value).to eq(["Nain", "Da"].to_json)
        end
      end

    end

    context "with a select attribute" do
      before do
        @countries = COUNTRIES.to_a
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, :type => :select, :collection => @countries)
        @span = nk.css("span")
      end

      it "should have a select data-type" do
        expect(@span.attribute("data-type").value).to eq("select")
      end

      it "should have a proper data collection" do
        expect(@span.attribute("data-collection").value).to eq(@countries.to_json)
      end

      it "should show the current country" do
        expect(@span.text).to eq("Italy")
      end

      it "should include the proper data-value" do
        expect(@span.attribute("data-value").value).to eq("2")
      end

      context "with an apostrophe in it" do
        before do
          @apostrophe_countries = [[1, "Joe's Country"], [2, "Bob's Country"]]
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, :type => :select, :collection => @apostrophe_countries)
          @span = nk.css("span")
        end

        it "should have a proper data collection" do
          expect(@span.attribute("data-collection").value).to eq(@apostrophe_countries.to_json)
        end
      end
    end
  end

  describe "#best_in_place_if" do
    context "when the parameters are valid" do
      before do
        @user = User.new :name => "Lucia",
          :last_name => "Napoli",
          :email => "lucianapoli@gmail.com",
          :height => "5' 5\"",
          :address => "Via Roma 99",
          :zip => "25123",
          :country => "2",
          :receive_email => false,
          :birth_date => Time.now.utc.to_date,
          :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
          :money => 150
        @options = {}
      end

      context "when the condition is true" do
        before {@condition = true}

        it "should work with array-like objects in order to provide support to namespaces" do
          nk = Nokogiri::HTML.parse(helper.best_in_place_if @condition, [:admin, @user], :name)
          span = nk.css("span")
          expect(span.text).to eq("Lucia")
        end

        context "when the options parameter is left off" do
          it "should call best_in_place with the rest of the parameters and empty options" do
            expect(helper).to receive(:best_in_place).with(@user, :name, {})
            helper.best_in_place_if @condition, @user, :name
          end
        end

        context "when the options parameter is included" do
          it "should call best_in_place with the rest of the parameters" do
            expect(helper).to receive(:best_in_place).with(@user, :name, @options)
            helper.best_in_place_if @condition, @user, :name, @options
          end
        end
      end

      context "when the condition is false" do
        before {@condition = false}

        it "should work with array-like objects in order to provide support to namespaces" do
          expect(helper.best_in_place_if(@condition, [:admin, @user], :name)).to eq "Lucia"
        end

        it "should return the value of the field when the options value is left off" do
          expect(helper.best_in_place_if(@condition, @user, :name)).to eq "Lucia"
        end

        it "should return the value of the field when the options value is included" do
          expect(helper.best_in_place_if(@condition, @user, :name, @options)).to eq "Lucia"
        end
      end
    end
  end
end
