defmodule TwitterWeb.RegistrationControllerTest do
	use TwitterWeb.ConnCase
	alias Twitter.Repo
	alias Twitter.Accounts.User
	alias Twitter.Accounts.Guardian

	@valid_attrs %{email: "some@email.com", username: "some username", password: "some password", password_confirmation: "some password"}
  @invalid_attrs %{email: nil, username: nil, password: nil, password_confirmation: nil}

	test "New registration", %{conn: conn} do
    conn = get(conn,Routes.registration_path(conn, :new))

    assert html_response(conn, 200) =~ "Sign Up"
  end

  describe "Create registration User " do
  	test "redirects to timeline index when data is valid", %{conn: conn} do
	  	conn = post(conn, Routes.registration_path(conn, :create), params: @valid_attrs)

	  	assert redirected_to(conn) =~ Routes.timeline_path(conn, :index, sort: false)
	  	
	  	user = Repo.get_by(User, email: "some@email.com")

	  	assert user
	  	assert Guardian.Plug.authenticated?(conn)
	  	assert user.id == Guardian.Plug.current_resource(conn).id
	  end

	  test "renders errors when data is invalid", %{conn: conn} do
	    conn = post(conn, Routes.registration_path(conn, :create),params: @invalid_attrs)

	    assert html_response(conn, 200) =~ "Invalid input"
	  end
  end
end