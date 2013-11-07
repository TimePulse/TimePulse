class PaginatedPaidQuery

  def find_for_page(page)
    @relation.paid.paginate(:per_page => 10, :page => page, :order => "paid_on DESC, created_at DESC")
  end

end
