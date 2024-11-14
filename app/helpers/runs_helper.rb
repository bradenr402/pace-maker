module RunsHelper
  def run_content_wrapper(run, team, turbo_frame, &content)
    content = capture(&content)
    return content if current_page?(run) || turbo_frame

    link_to run_path(run, team: team), team:, class: 'block space-y-4', data: { turbo: false } do
      content
    end
  end
end
