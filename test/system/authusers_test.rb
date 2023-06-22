require "application_system_test_case"

class AuthusersTest < ApplicationSystemTestCase
  setup do
    @authuser = authusers(:one)
  end

  test "visiting the index" do
    visit authusers_url
    assert_selector "h1", text: "Authusers"
  end

  test "creating a Authuser" do
    visit authusers_url
    click_on "New Authuser"

    check "Approved" if @authuser.approved
    fill_in "Approved by", with: @authuser.approved_by
    fill_in "Email", with: @authuser.email
    fill_in "Password digest", with: @authuser.password_digest
    fill_in "Username", with: @authuser.username
    click_on "Create Authuser"

    assert_text "Authuser was successfully created"
    click_on "Back"
  end

  test "updating a Authuser" do
    visit authusers_url
    click_on "Edit", match: :first

    check "Approved" if @authuser.approved
    fill_in "Approved by", with: @authuser.approved_by
    fill_in "Email", with: @authuser.email
    fill_in "Password digest", with: @authuser.password_digest
    fill_in "Username", with: @authuser.username
    click_on "Update Authuser"

    assert_text "Authuser was successfully updated"
    click_on "Back"
  end

  test "destroying a Authuser" do
    visit authusers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Authuser was successfully destroyed"
  end
end
