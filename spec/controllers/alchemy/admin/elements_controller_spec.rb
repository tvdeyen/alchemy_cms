# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::ElementsController do
    routes { Alchemy::Engine.routes }

    let(:page_version)         { create(:alchemy_page_version) }
    let(:element)              { create(:alchemy_element, page_version: page_version) }
    let(:element_in_clipboard) { create(:alchemy_element, page_version: page_version) }
    let(:clipboard)            { session[:alchemy_clipboard] = {} }

    before { authorize_user(:as_author) }

    describe "#index" do
      let!(:page_version)    { create(:alchemy_page_version) }
      let!(:element)         { create(:alchemy_element, page_version: page_version) }
      let!(:nested_element)  { create(:alchemy_element, :nested, page_version: page_version) }
      let!(:hidden_element)  { create(:alchemy_element, page_version: page_version, public: false) }

      context "with fixed elements" do
        let!(:fixed_element) do
          create(:alchemy_element, :fixed, page_version: page_version)
        end

        let!(:fixed_hidden_element) do
          create(:alchemy_element, :fixed, public: false, page_version: page_version)
        end

        it "assigns fixed elements" do
          get :index, params: { page_version_id: page_version.id }
          expect(assigns(:fixed_elements)).to eq([fixed_element, fixed_hidden_element])
        end
      end

      it "assigns elements" do
        get :index, params: { page_version_id: page_version.id }
        expect(assigns(:elements)).to eq([element, nested_element.parent_element, hidden_element])
      end
    end

    describe "#order" do
      let!(:element_1)   { create(:alchemy_element) }
      let!(:element_2)   { create(:alchemy_element, page_version: page_version) }
      let!(:element_3)   { create(:alchemy_element, page_version: page_version) }
      let(:element_ids) { [element_1.id, element_3.id, element_2.id] }
      let(:page_version) { element_1.page_version }

      it "sets new position for given element ids" do
        post :order, params: { element_ids: element_ids }, xhr: true
        expect(Element.all.pluck(:id, :position)).to eq([
          [element_1.id, 1],
          [element_3.id, 2],
          [element_2.id, 3],
        ])
      end

      context "with missing [:element_ids] param" do
        it "does not raise any error and silently rejects to order" do
          expect { post :order, xhr: true }.to_not raise_error
        end
      end

      context "when nested inside parent element" do
        let(:parent) { create(:alchemy_element) }

        it "touches the cache key of parent element" do
          parent.update_column(:updated_at, 3.days.ago)
          expect {
            post :order, params: {
              element_ids: element_ids,
              parent_element_id: parent.id,
            }, xhr: true
          }.to change { parent.reload.updated_at }
        end

        it "assigns parent element id to each element" do
          post :order, params: {
                    element_ids: element_ids,
                    parent_element_id: parent.id,
                  }, xhr: true
          [element_1, element_2, element_3].each do |element|
            expect(element.reload.parent_element_id).to eq parent.id
          end
        end
      end
    end

    describe "#new" do
      let(:page_version) { create(:alchemy_page_version) }

      it "assign variable for all available element definitions" do
        expect_any_instance_of(Alchemy::Page).to receive(:available_element_definitions)
        get :new, params: {page_version_id: page_version.id}
      end

      context "with elements in clipboard" do
        let(:element) { create(:alchemy_element, page_version: page_version) }
        let(:clipboard_items) { [{"id" => element.id.to_s, "action" => "copy"}] }

        before { clipboard["elements"] = clipboard_items }

        it "should load all elements from clipboard" do
          expect(Element).to receive(:all_from_clipboard_for_page).and_return(clipboard_items)
          get :new, params: {page_version_id: page_version.id}
          expect(assigns(:clipboard_items)).to eq(clipboard_items)
        end
      end
    end

    describe "#create" do
      describe "insertion position" do
        before { element }

        it "should insert the element at bottom of list" do
          post :create, params: { element: { name: "news", page_version_id: page_version.id } }, xhr: true
          expect(page_version.elements.count).to eq(2)
          expect(page_version.elements.order(:position).last.name).to eq("news")
        end

        context "on a page with a setting for insert_elements_at of top" do
          before do
            expect(PageLayout).to receive(:get).at_least(:once).and_return({
              "name" => "news",
              "elements" => ["news"],
              "insert_elements_at" => "top",
            })
          end

          it "should insert the element at top of list" do
            post :create, params: { element: { name: "news", page_version_id: page_version.id } }, xhr: true
            expect(page_version.elements.count).to eq(2)
            expect(page_version.elements.order(:position).first.name).to eq("news")
          end
        end
      end

      context "with parent_element_id given" do
        let(:parent_element) do
          create(:alchemy_element, :with_nestable_elements, page_version: page_version)
        end

        it "creates the element in the parent element" do
          post :create, params: { element: { name: "slide", page_version_id: page_version.id, parent_element_id: parent_element.id } }, xhr: true
          expect(Alchemy::Element.last.parent_element_id).to eq(parent_element.id)
        end
      end

      context "pasting from clipboard" do
        render_views

        before do
          clipboard["elements"] = [{ "id" => element_in_clipboard.id.to_s, "action" => "cut" }]
        end

        it "should create an element from clipboard" do
          post :create, params: { paste_from_clipboard: element_in_clipboard.id, element: { page_version_id: page_version.id } }, xhr: true
          expect(response.status).to eq(200)
          expect(response.body).to match(/Successfully added new element/)
        end

        context "and with cut as action parameter" do
          it "should also remove the element id from clipboard" do
            post :create, params: { paste_from_clipboard: element_in_clipboard.id, element: { page_version_id: page_version.id } }, xhr: true
            expect(session[:alchemy_clipboard]["elements"].detect { |item| item["id"] == element_in_clipboard.id.to_s }).to be_nil
          end
        end

        context "with parent_element_id given" do
          let(:element_in_clipboard) { create(:alchemy_element, :nested, page_version: page_version) }
          let(:parent_element) { create(:alchemy_element, :with_nestable_elements) }

          it "moves the element to new parent" do
            post :create, params: { paste_from_clipboard: element_in_clipboard.id, element: { page_version_id: page_version.id, parent_element_id: parent_element.id } }, xhr: true
            expect(Alchemy::Element.last.parent_element_id).to eq(parent_element.id)
          end
        end
      end

      context "if element could not be saved" do
        subject { post :create, params: { element: { page_version_id: page_version.id } } }

        before do
          expect_any_instance_of(Element).to receive(:save).and_return false
        end

        it "renders the new template" do
          expect(subject).to render_template(:new)
        end
      end
    end

    describe "#update" do
      let(:element) { build_stubbed(:alchemy_element) }
      let(:contents_parameters) { ActionController::Parameters.new(1 => {ingredient: "Title"}) }
      let(:element_parameters) { ActionController::Parameters.new(tag_list: "Tag 1", public: false) }

      before do
        expect(Element).to receive(:find).and_return element
        expect(controller).to receive(:contents_params).and_return(contents_parameters)
      end

      it "updates all contents in element" do
        expect(element).to receive(:update_contents).with(contents_parameters)
        put :update, params: { id: element.id }, xhr: true
      end

      it "updates the element and responses with json" do
        expect(controller).to receive(:element_params).and_return(element_parameters)
        expect(element).to receive(:update_contents).and_return(true)
        expect(element).to receive(:update!).with(element_parameters).and_return(true)
        put :update, params: { id: element.id }, xhr: true
        expect(response.media_type).to eq("application/json")
      end

      context "failed validations" do
        before do
          expect(element).to receive(:update_contents).and_return(false)
        end

        it "returns validation error as json" do
          put :update, params: { id: element.id }, xhr: true
          expect(response.media_type).to eq("application/json")
          expect(response.status).to eq(422)
          json = JSON.parse(response.body)
          expect(json).to have_key("message")
          expect(json["message"]).to have_content("Validation failed")
          expect(json).to have_key("element")
        end
      end
    end

    describe "#destroy" do
      subject { delete :destroy, params: { id: element.id }, xhr: true }

      let!(:element) { create(:alchemy_element) }

      it "deletes the element" do
        expect { subject }.to change(Alchemy::Element, :count).to(0)
        expect(subject.status).to be 200
      end
    end

    describe "params security" do
      context "contents params" do
        let(:parameters) { ActionController::Parameters.new(contents: { 1 => { ingredient: "Title" } }) }

        specify ":contents is required" do
          expect(controller.params).to receive(:fetch).and_return(parameters)
          controller.send :contents_params
        end

        specify "everything is permitted" do
          expect(controller).to receive(:params).and_return(parameters)
          expect(parameters).to receive(:fetch).and_return(parameters)
          expect(parameters).to receive(:permit!)
          controller.send :contents_params
        end
      end

      context "element params" do
        let(:parameters) { ActionController::Parameters.new(element: { public: true }) }

        before do
          expect(controller).to receive(:params).and_return(parameters)
          expect(parameters).to receive(:fetch).with(:element, {}).and_return(parameters)
        end

        context "with taggable element" do
          before do
            controller.instance_variable_set(:'@element', mock_model(Element, taggable?: true))
          end

          specify ":tag_list is permitted" do
            expect(parameters).to receive(:permit).with(:tag_list)
            controller.send :element_params
          end
        end

        context "with not taggable element" do
          before do
            controller.instance_variable_set(:'@element', mock_model(Element, taggable?: false))
          end

          specify ":tag_list is not permitted" do
            expect(parameters).to_not receive(:permit)
            controller.send :element_params
          end
        end
      end
    end

    describe "#fold" do
      subject { post :fold, params: { id: element.id }, xhr: true }

      let(:response_data) { JSON.parse(subject.body) }

      before do
        expect(Element).to receive(:find) { element }
      end

      context "if element is folded" do
        let(:element) { create(:alchemy_element, folded: true) }

        it "sets folded to false and response with JSON" do
          expect(response_data).to have_key("folded")
          expect(response_data["folded"]).to be false
        end
      end

      context "if element is not folded" do
        let(:element) { create(:alchemy_element, folded: false) }

        it "sets folded to true." do
          expect(response_data).to have_key("folded")
          expect(response_data["folded"]).to be true
        end
      end
    end
  end
end
