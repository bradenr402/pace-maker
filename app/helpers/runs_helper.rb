module RunsHelper
  def run_content_wrapper(run, team, turbo_frame, &content)
    if current_page?(run) || turbo_frame
      capture(&content)
    else
      link_to run, data: { turbo: false }, run:, team:, class: 'block space-y-4' do
        capture(&content)
      end
    end
  end
end
