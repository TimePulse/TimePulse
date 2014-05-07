class PaginatedUnpaidQuery

  def find_for_page(page)
    @relation.unpaid.order(due_on: :desc, created_at: :desc).paginate(:per_page => 10, :page => page)
  end

end
