module Comments::CommentsHelper
  def total_replies_count(comment)
    count = comment.reply_count
    comment.replies.each do |reply|
      count += total_replies_count(reply)
    end
    count
  end
end
