defmodule TwitterWeb.SessionControllerTest do
	use TwitterWeb.ConnCase

	alias Twitter.{Repo, Accounts, Accounts.Guardian, Accounts.User}

	@secret OneTimePassEcto.Base.gen_secret(32)
  @valid_otp_attrs %{secret: @secret, otp: OneTimePassEcto.Base.gen_totp(@secret, [{:interval_length, 120}])}

	def otp_fixture(attrs \\ %{}) do
    {:ok, onetimepass} = 
      attrs
      |> Enum.into(@valid_otp_attrs)
      |> Accounts.insert_otp_token

    onetimepass
  end

  describe "new" do
  	test "login with no session before", %{conn: conn} do
	    conn = get(conn, Routes.session_path(conn, :new))

	    assert html_response(conn, 200) =~ "Log in"
	  end

	  test "login with session before", %{conn: conn} do
	  	user = user_fixture()
	  	conn = Guardian.Plug.sign_in(conn, user)
	    conn = get(conn, Routes.session_path(conn, :new))

	    assert redirected_to(conn) =~ Routes.timeline_path(conn, :index, sort: false) 
	  end
  end
	
	test "otp", %{conn: conn} do
    conn = get(conn, Routes.session_path(conn, :otp))

    assert html_response(conn, 200) =~ "OTP Login"
  end

  describe "otp_login" do
  	test "when data is valid", %{conn: conn} do
	  	user = user_fixture()
	    conn = post(conn, Routes.session_path(conn, :otp_login), otp: %{email: user.email})

	    assert html_response(conn, 200) =~ "Submit OTP Token"
	    # get otp 
	  end

	  test "when data is invalid", %{conn: conn} do
	    conn = post(conn, Routes.session_path(conn, :otp_login), otp: %{email: "no@exist.com"})

	    assert html_response(conn, 200) =~ "Email does not exist"
	  end
  end

  describe "otp_submit" do
  	test "when data is valid", %{conn: conn} do
	  	otp = otp_fixture()
	    user = user_fixture()

	    conn = post(conn, Routes.session_path(conn, :otp_submit), %{email: user.email, otp: %{otp_pass: otp.otp}})

	    assert redirected_to(conn) =~ Routes.timeline_path(conn, :index, sort: false)

	    user = Repo.get_by(User, email: user.email)

	  	assert Guardian.Plug.authenticated?(conn)
	  	assert user.id == Guardian.Plug.current_resource(conn).id
	  end

	  test "when data is invalid otp", %{conn: conn} do
	  	otp = otp_fixture(%{secret: @secret, otp: OneTimePassEcto.Base.gen_totp(@secret)})
	    user = user_fixture()
	    conn = post(conn, Routes.session_path(conn, :otp_submit), %{email: user.email, otp: %{otp_pass: otp.otp}})

	    assert html_response(conn, 200) =~ "invalid_otp"
	  end

	  test "when data is invalid credentials", %{conn: conn} do
	  	user = user_fixture()
	    conn = post(conn, Routes.session_path(conn, :otp_submit), %{email: user.email, otp: %{otp_pass: "123456"}})

	    assert html_response(conn, 200) =~ "invalid_credentials"
	  end
  end

  describe "create" do
  	test "when data is valid", %{conn: conn} do
  		user = user_fixture()
  		conn = post(conn, Routes.session_path(conn, :create), session: %{email: user.email, password: user.password })

  		assert redirected_to(conn) =~ Routes.timeline_path(conn, :index, sort: false) 

  		user = Repo.get_by(User, email: user.email)

	  	assert Guardian.Plug.authenticated?(conn)
	  	assert user.id == Guardian.Plug.current_resource(conn).id
  	end

  	test "when data is invalid", %{conn: conn} do
  		conn = post(conn, Routes.session_path(conn, :create), session: %{email: "no@exist.email", password: "noexist" })

  		assert html_response(conn, 200) =~ "Invalid Email or Password" 
  	end
  end

  test "delete session", %{conn: conn} do
  	user = user_fixture()
  	conn = Guardian.Plug.sign_in(conn, user)
  	conn = delete(conn, Routes.session_path(conn, :delete))

  	assert redirected_to(conn) =~ Routes.session_path(conn, :new)
  	refute Guardian.Plug.authenticated?(conn)
  end
end