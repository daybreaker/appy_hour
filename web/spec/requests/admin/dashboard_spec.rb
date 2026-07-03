require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /admin" do
    context "when not logged in" do
      it "redirects to login" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as regular user" do
      it "redirects to root" do
        sign_in create(:user, role: :user)
        get admin_root_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when logged in as editor" do
      it "redirects to root" do
        sign_in create(:user, role: :editor)
        get admin_root_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when logged in as admin" do
      before { sign_in create(:user, role: :admin) }

      it "renders the dashboard" do
        get admin_root_path
        expect(response).to have_http_status(:ok)
      end

      it "displays counts for the approval queue" do
        create(:happy_hour, status: :pending)
        create(:venue, needs_investigation: true)
        get admin_root_path
        expect(response.body).to include("1")
      end
    end
  end
end
