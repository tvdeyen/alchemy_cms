# frozen_string_literal: true

require 'ostruct'
require 'rails_helper'

module Alchemy
  describe Admin::PagesController do
    context 'a guest' do
      it 'cannot access pages index page' do
        get admin_pages_path
        expect(request).to redirect_to(Alchemy.login_path)
      end
    end

    context 'a member' do
      before { authorize_user(build(:alchemy_dummy_user)) }

      it 'cannot access pages index page' do
        get admin_pages_path
        expect(request).to redirect_to(root_path)
      end
    end

    context 'with logged in editor user' do
      let(:user) { build(:alchemy_dummy_user, :as_editor) }

      before { authorize_user(user) }

      describe '#index' do
        let!(:language) { create(:alchemy_language) }

        it "it assigns current language" do
          get admin_pages_path
          expect(assigns(:language)).to eq(language)
        end

        context 'with multiple pages of different languages' do
          let!(:page) { create(:alchemy_page, language: language) }
          let!(:page2) { create(:alchemy_page, language: create(:alchemy_language, :klingon)) }

          it 'assigns pages of current language only' do
            get admin_pages_path
            expect(assigns(:pages)).to eq([page])
          end
        end

        context 'with parent_id query' do
          let!(:page) { create(:alchemy_page, language: language) }
          let!(:page2) { create(:alchemy_page, parent: page) }

          it 'assigns pages having parent id' do
            get admin_pages_path(q: {parent_id_eq: page.id})
            expect(assigns(:pages)).to eq([page2])
          end

          it 'assigns parent' do
            get admin_pages_path(q: {parent_id_eq: page.id})
            expect(assigns(:parent)).to eq(page)
          end
        end

        context 'without any pages' do
          it "assigns a new page" do
            get admin_pages_path
            expect(assigns(:page)).to be_an_instance_of(Alchemy::Page)
            expect(assigns(:page).language).to eq(language)
          end
        end
      end

      describe "#flush" do
        let(:content_page_1) do
          time = Time.current - 5.days
          create :alchemy_page,
            public_on: time,
            name: "content page 1",
            published_at: time
        end

        let(:content_page_2) do
          time = Time.current - 8.days
          create :alchemy_page,
            public_on: time,
            name: "content page 2",
            published_at: time
        end

        let(:layout_page_1) do
          create :alchemy_page,
            layoutpage: true,
            name: "layout_page 1",
            published_at: Time.current - 5.days
        end

        let(:layout_page_2) do
          create :alchemy_page,
            layoutpage: true,
            name: "layout_page 2",
            published_at: Time.current - 8.days
        end

        let(:content_pages) { [content_page_1, content_page_2] }
        let(:layout_pages) { [layout_page_1, layout_page_2] }

        it "should update the published_at field of content pages" do
          content_pages

          travel_to(Time.current) do
            post flush_admin_pages_path, xhr: true
            # Reloading because published_at was directly updated in the database.
            content_pages.map(&:reload)
            content_pages.each do |page|
              expect(page.published_at).to eq(Time.current)
            end
          end
        end

        it "should update the published_at field of layout pages" do
          layout_pages

          travel_to(Time.current) do
            post flush_admin_pages_path, xhr: true
            # Reloading because published_at was directly updated in the database.
            layout_pages.map(&:reload)
            layout_pages.each do |page|
              expect(page.published_at).to eq(Time.current)
            end
          end
        end
      end

      describe '#new' do
        context "pages in clipboard" do
          let(:page) { mock_model(Alchemy::Page, name: 'Foobar') }

          before do
            allow_any_instance_of(described_class).to receive(:get_clipboard).with('pages') do
              [{'id' => page.id.to_s, 'action' => 'copy'}]
            end
          end

          it "should load all pages from clipboard" do
            get new_admin_page_path(page_id: page.id), xhr: true
            expect(assigns(:clipboard_items)).to be_kind_of(Array)
          end
        end
      end

      describe '#show' do
        let(:language) { build_stubbed(:alchemy_language, locale: 'nl') }
        let(:page) { build_stubbed(:alchemy_page, language: language) }

        before do
          expect(Page).to receive(:find).with(page.id.to_s).and_return(page)
          allow(Page).to receive(:home_page_for).and_return(mock_model(Alchemy::Page))
        end

        it "should assign @preview_mode with true" do
          get admin_page_path(page)
          expect(assigns(:preview_mode)).to eq(true)
        end

        it "should store page as current preview" do
          expect(Page).to receive(:current_preview=).with(page)
          get admin_page_path(page)
        end

        it "should set the I18n locale to the pages language code" do
          get admin_page_path(page)
          expect(::I18n.locale).to eq(:nl)
        end

        it "renders the application layout" do
          get admin_page_path(page)
          expect(response).to render_template(layout: 'application')
        end

        context 'when layout is set to custom' do
          before do
            allow(Alchemy::Config).to receive(:get) do |arg|
              arg == :admin_page_preview_layout ? 'custom' : Alchemy::Config.parameter(arg)
            end
          end

          it "it renders custom layout instead" do
            get admin_page_path(page)
            expect(response).to render_template(layout: 'custom')
          end
        end
      end

      describe "#configure" do
        context "with page having nested urlname" do
          let(:page) { create(:alchemy_page, name: 'Foobar', urlname: 'foobar') }

          it "should always show the slug" do
            get configure_admin_page_path(page), xhr: true
            expect(response.body).to match /value="foobar"/
          end
        end
      end

      describe "#update" do
        let(:page) { create(:alchemy_page) }

        subject do
          patch(admin_page_path(page), params: params, xhr: true)
          response.body
        end

        context "with valid page params" do
          let(:params) do
            {
              page: {
                name: 'New Name'
              }
            }
          end

          let(:referer) { '/admin/pages/configure' }

          before do
            expect_any_instance_of(ActionDispatch::Request).to receive(:referer) do
              referer
            end
          end

          it "displays success message" do
            is_expected.to match /Alchemy\.growl\("New Name saved"\)/
          end

          context "on page edit screen" do
            let(:referer) { '/admin/pages/edit' }

            it "reloads the preview" do
              is_expected.to match /Alchemy\.reloadPreview\(\)/
            end
          end
        end

        context "with invalid page params" do
          let(:params) do
            {
              page: {
                name: ''
              }
            }
          end

          it "displays form again" do
            is_expected.to have_selector('form.edit_page')
          end
        end
      end

      describe '#create' do
        subject { post admin_pages_path(page: page_params) }

        let(:parent) { create(:alchemy_page) }

        let(:page_params) do
          {
            parent_id: parent.id,
            name: 'new Page',
            page_layout: 'standard'
          }
        end

        context "a new page" do
          it "is nested under given parent" do
            subject
            expect(Alchemy::Page.last.parent_id).to eq(parent.id)
          end

          it "redirects to edit page template" do
            expect(subject).to redirect_to(edit_admin_page_path(Alchemy::Page.last))
          end

          context "if new page can not be saved" do
            let(:page_params) do
              {
                parent_id: parent.id,
                name: 'new Page'
              }
            end

            it "renders the create form" do
              expect(subject).to render_template(:new)
            end
          end

          context "with redirect_to in params" do
            subject do
              post admin_pages_path(page: page_params, redirect_to: admin_pictures_path)
            end

            it "should redirect to given url" do
              expect(subject).to redirect_to(admin_pictures_path)
            end

            context "when a new page cannot be created" do
              let(:page_params) do
                {
                  parent_id: parent.id,
                  name: 'new Page'
                }
              end

              it "should render the `new` template" do
                expect(subject).to render_template(:new)
              end
            end
          end

          context 'if page is scoped' do
            context 'user role does not match' do
              before do
                allow_any_instance_of(Page).to receive(:editable_by?).with(user).and_return(false)
              end

              it 'redirects to admin pages path' do
                post admin_pages_path(page: page_params)
                expect(response).to redirect_to(admin_pages_path)
              end
            end
          end
        end

        context "with paste_from_clipboard in parameters" do
          let(:page_in_clipboard) { create(:alchemy_page) }

          it "should call Page#copy_and_paste" do
            expect(Page).to receive(:copy_and_paste).
              with(page_in_clipboard, parent, page_params[:name])
            post admin_pages_path(
              page: page_params,
              paste_from_clipboard: page_in_clipboard.id
            ), xhr: true
          end
        end
      end

      describe '#edit' do
        let!(:page)       { create(:alchemy_page) }
        let!(:other_user) { create(:alchemy_dummy_user, :as_author) }

        context 'if page is locked by another user' do
          before { page.lock_to!(other_user) }

          context 'that is signed in' do
            before do
              expect_any_instance_of(DummyUser).to receive(:logged_in?).and_return(true)
            end

            it 'redirects to sitemap' do
              get edit_admin_page_path(page)
              expect(response).to redirect_to(admin_pages_path)
            end
          end

          context 'that is not signed in' do
            before do
              expect_any_instance_of(DummyUser).to receive(:logged_in?).and_return(false)
            end

            it 'renders the edit view' do
              get edit_admin_page_path(page)
              expect(response).to render_template(:edit)
            end
          end
        end

        context 'if page is locked by myself' do
          before do
            expect_any_instance_of(Page).to receive(:locker).at_least(:once) { user }
            expect(user).to receive(:logged_in?).and_return(true)
          end

          it 'renders the edit view' do
            get edit_admin_page_path(page)
            expect(response).to render_template(:edit)
          end

          it 'does not lock the page again' do
            expect_any_instance_of(Alchemy::Page).to_not receive(:lock_to!)
            get edit_admin_page_path(page)
          end
        end

        context 'if page is not locked' do
          before do
            expect_any_instance_of(Page).to receive(:locker).at_least(:once) { nil }
          end

          it 'renders the edit view' do
            get edit_admin_page_path(page)
            expect(response).to render_template(:edit)
          end

          it "lockes the page to myself" do
            expect_any_instance_of(Page).to receive(:lock_to!)
            get edit_admin_page_path(page)
          end
        end

        context 'if page is scoped' do
          context 'to a single role' do
            context 'user role matches' do
              before do
                expect_any_instance_of(Page).to receive(:editable_by?).at_least(:once) { true }
              end

              it 'renders the edit view' do
                get edit_admin_page_path(page)
                expect(response).to render_template(:edit)
              end
            end

            context 'user role does not match' do
              before do
                expect_any_instance_of(Page).to receive(:editable_by?).at_least(:once) { false }
              end

              it 'redirects to admin dashboard' do
                get edit_admin_page_path(page)
                expect(response).to redirect_to(admin_dashboard_path)
              end
            end
          end
        end
      end

      describe '#destroy' do
        let(:clipboard) { [{'id' => page.id.to_s}] }
        let(:page) { create(:alchemy_page, :public) }

        before do
          allow_any_instance_of(described_class).to receive(:get_clipboard).with('pages') do
            clipboard
          end
        end

        it "should also remove the page from clipboard" do
          delete admin_page_path(page), xhr: true
          expect(clipboard).to be_empty
        end
      end

      describe '#publish' do
        let(:page) { create(:alchemy_page, published_at: 3.days.ago) }

        it "should publish the page" do
          expect {
            post publish_admin_page_path(page)
          }.to change { page.reload.published_at }
        end
      end

      describe '#visit' do
        subject do
          post visit_admin_page_path(page)
        end

        let(:page) { create(:alchemy_page, urlname: 'home', site: site) }

        context "when the pages site is a catch-all" do
          let(:site) { create(:alchemy_site, host: "*") }

          it "should redirect to the page path" do
            is_expected.to redirect_to("/home")
          end
        end

        context "when pages site is a real host" do
          let(:site) { create(:alchemy_site, host: "reallygoodsite.com") }

          it "should redirect to the page path on that host" do
            is_expected.to redirect_to("http://reallygoodsite.com/home")
          end
        end
      end

      describe '#unlock' do
        subject { post unlock_admin_page_path(page), xhr: true }

        let(:page) { mock_model(Alchemy::Page, name: 'Best practices') }

        before do
          allow(Page).to receive(:find).with(page.id.to_s).and_return(page)
          allow(page).to receive(:editable_by?).with(user).and_return(true)
          allow(Page).to receive(:from_current_site).and_return(double(locked_by: nil))
          expect(page).to receive(:unlock!) { true }
        end

        it "should unlock the page" do
          is_expected.to eq(200)
        end

        context 'requesting for html format' do
          subject { post unlock_admin_page_path(page) }

          it "should redirect to admin_pages_path" do
            is_expected.to redirect_to(admin_pages_path)
          end

          context 'if passing :redirect_to through params' do
            subject { post unlock_admin_page_path(page, redirect_to: 'this/path') }

            it "should redirect to the given path" do
              is_expected.to redirect_to('this/path')
            end
          end
        end
      end
    end
  end
end
