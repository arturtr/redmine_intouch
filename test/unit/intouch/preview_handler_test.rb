class Intouch::PreviewHandlerTest < ActiveSupport::TestCase
  test 'should not respond when setting is turned off' do
    Setting.expects('plugin_redmine_intouch').returns({})
    api = mock
    update = mock
    handler = Intouch::PreviewHandler.new(api, update)
    api.expects(:answer_callback_query).never
    handler.call
  end

  test 'should not respond to invalid data type' do
    Setting.expects('plugin_redmine_intouch').returns({ 'telegram_preview' => 1 })
    api = mock
    update = mock
    update.stubs(:data).returns('{ "type": "invalid" }')
    handler = Intouch::PreviewHandler.new(api, update)
    api.expects(:answer_callback_query).never
    handler.call
  end

  test 'should not respond when issue can not be found' do
    Setting.expects('plugin_redmine_intouch').returns({ 'telegram_preview' => 1 })
    api = mock
    update = mock
    update.stubs(:data).returns('{ "type": "issue_preview", "issue_id": 1 }')
    Issue.expects(:find_by).with(id: 1).returns(nil)
    handler = Intouch::PreviewHandler.new(api, update)
    api.expects(:answer_callback_query).never
    handler.call
  end

  test 'should not respond when user is not allowed to view issues' do
    Setting.expects('plugin_redmine_intouch').returns({ 'telegram_preview' => 1 })
    api = mock
    update = mock
    issue = mock
    project = mock
    from = mock
    telegram_account = mock
    query_id = mock
    user = mock
    telegram_id = mock
    issue.stubs(:project).returns(project)
    update.stubs(:data).returns('{ "type": "issue_preview", "issue_id": 1 }')
    update.stubs(:from).returns(from)
    update.stubs(:id).returns(query_id)
    from.stubs(:id).returns(telegram_id)
    telegram_account.stubs(:user).returns(user)
    user.stubs(:allowed_to?).with(:view_issues, project).returns(false)
    Issue.expects(:find_by).with(id: 1).returns(issue)
    TelegramAccount.expects(:find_by).with(telegram_id: telegram_id).returns(telegram_account)
    handler = Intouch::PreviewHandler.new(api, update)
    api.expects(:answer_callback_query).never
    handler.call
  end

  test 'should respond when everything is fine' do
    Setting.expects('plugin_redmine_intouch').returns({ 'telegram_preview' => 1 })
    api = mock
    update = mock
    issue = mock
    project = mock
    from = mock
    telegram_account = mock
    query_id = mock
    result_text = mock
    user = mock
    telegram_id = mock
    issue.stubs(:project).returns(project)
    update.stubs(:data).returns('{ "type": "issue_preview", "issue_id": 1 }')
    update.stubs(:from).returns(from)
    update.stubs(:id).returns(query_id)
    from.stubs(:id).returns(telegram_id)
    telegram_account.stubs(:user).returns(user)
    user.stubs(:allowed_to?).with(:view_issues, project).returns(true)
    Issue.expects(:find_by).with(id: 1).returns(issue)
    TelegramAccount.expects(:find_by).with(telegram_id: telegram_id).returns(telegram_account)
    Intouch::PreviewHandler::Text.expects(:normalize).with(issue).returns(result_text)
    handler = Intouch::PreviewHandler.new(api, update)
    api.expects(:answer_callback_query).with(callback_query_id: query_id, text: result_text, show_alert: true, cache_time: 30)
    handler.call
  end
end
