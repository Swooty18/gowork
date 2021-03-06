require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:misha)
  end
  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {
      first_name: '',
      last_name: '',
      email: 'foo@invali',
      city: '',
      description: '',
      password: 'foo',
      password_confirmation: 'bar'
    } }
    assert_template 'users/edit'
  end

  test 'successful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    first_name = 'FirstName'
    last_name = 'LastName'
    email = 'foo@bar.com'
    city = 'CityUk'
    description = 'Something about me'
    patch user_path(@user), params: { user: {
      first_name: first_name,
      last_name: last_name,
      email: email,
      city: city,
      description: description,
      password: '',
      password_confirmation: ''
    } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal first_name, @user.first_name
    assert_equal last_name, @user.last_name
    assert_equal email, @user.email
    assert_equal city, @user.city
    assert_equal description, @user.description
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    first_name = 'FirstName'
    last_name = 'LastName'
    email = 'foo@bar.com'
    city = 'CityUk'
    description = 'Something about me'
    patch user_path(@user), params: { user: {
      first_name: first_name,
      last_name: last_name,
      email: email,
      city: city,
      description: description,
      password: '',
      password_confirmation: ''
    } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal first_name, @user.first_name
    assert_equal last_name, @user.last_name
    assert_equal email, @user.email
    assert_equal city, @user.city
    assert_equal description, @user.description
  end
end