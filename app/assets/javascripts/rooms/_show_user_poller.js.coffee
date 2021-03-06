class @RoomsShowUsersPoller
  constructor: (users_url) ->
    @users_url = users_url
    setTimeout((=> @refreshList()), 300)
    setTimeout((=> @runRefreshLoop()), 5000)

  runRefreshLoop: =>
    @refreshList()
    setTimeout((=> @runRefreshLoop()), 5000)

  refreshList: =>
    $.getJSON(@users_url, @renderUsers)

  renderUsers: (users) =>
    @cleanUsers(users)
    for user in users
      @addUser(user)

  addUser: (user) =>
    if $(".user-#{user.user_id}").length > 0
      $(".user-#{user.user_id}").replaceWith( Mustache.to_html($('#user_with_client_ids_template').html(), user) )
    else
      $('#online_agents').append Mustache.to_html($('#user_with_client_ids_template').html(), user)

  cleanUsers: (online_users) =>
    users_in_list = $("#online_agents").find(".user")
    for user in users_in_list
      user_id = $(user).data('userId')
      @result = null

      for online_user in online_users
        if online_user.user_id == user_id
          @result = online_user

      $(user).remove() unless @result != null
