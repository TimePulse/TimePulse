class PaginatedUnpaidQuery

  def find_for_page(page)
    @relation.unpaid.paginate(:per_page => 10, :page => page, :order => "due_on DESC, created_at DESC")
  end

end
